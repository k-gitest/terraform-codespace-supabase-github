name: CD Pipeline

on:
  workflow_run:
    workflows: ["CI Pipeline"]
    types:
      - completed
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deploy environment'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

env:
  NODE_VERSION: '${node_version}'
  CLOUDFLARE_PROJECT_NAME: '${cloudflare_project_name}'
  CLOUDFLARE_ACCOUNT_ID: '${cloudflare_account_id}'

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' || github.event_name == 'workflow_dispatch' }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build application
      run: npm run build
      env:
        NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
        NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
    
    - name: Determine deployment environment
      id: env
      run: |
        if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
          echo "environment=${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
          echo "branch=${{ github.ref_name }}" >> $GITHUB_OUTPUT
        elif [[ "${{ github.event.workflow_run.head_branch }}" == "main" ]]; then
          echo "environment=production" >> $GITHUB_OUTPUT
          echo "branch=main" >> $GITHUB_OUTPUT
        elif [[ "${{ github.event.workflow_run.head_branch }}" == "develop" ]]; then
          echo "environment=staging" >> $GITHUB_OUTPUT
          echo "branch=staging" >> $GITHUB_OUTPUT
        else
          echo "environment=preview" >> $GITHUB_OUTPUT
          echo "branch=preview" >> $GITHUB_OUTPUT
        fi
    
    - name: Deploy to Cloudflare Pages
      uses: cloudflare/pages-action@v1
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ env.CLOUDFLARE_ACCOUNT_ID }}
        projectName: ${{ env.CLOUDFLARE_PROJECT_NAME }}
        directory: dist
        gitHubToken: ${{ secrets.GITHUB_TOKEN }}
        branch: ${{ steps.env.outputs.branch }}
    
    - name: Set deployment URL
      id: url
      run: |
        if [[ "${{ steps.env.outputs.environment }}" == "production" ]]; then
          echo "url=https://${CLOUDFLARE_PROJECT_NAME}.pages.dev" >> $GITHUB_OUTPUT
        elif [[ "${{ steps.env.outputs.environment }}" == "staging" ]]; then
          echo "url=https://staging.${CLOUDFLARE_PROJECT_NAME}.pages.dev" >> $GITHUB_OUTPUT
        else
          echo "url=https://preview.${CLOUDFLARE_PROJECT_NAME}.pages.dev" >> $GITHUB_OUTPUT
        fi
    
    - name: Create deployment record
      uses: actions/github-script@v7
      with:
        script: |
          const deployment = await github.rest.repos.createDeployment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            ref: context.sha,
            environment: '${{ steps.env.outputs.environment }}',
            description: 'Deploy to Cloudflare Pages (${{ steps.env.outputs.environment }})',
            required_contexts: []
          });
          
          await github.rest.repos.createDeploymentStatus({
            owner: context.repo.owner,
            repo: context.repo.repo,
            deployment_id: deployment.data.id,
            state: 'success',
            environment_url: '${{ steps.url.outputs.url }}',
            description: 'Deployment to ${{ steps.env.outputs.environment }} successful'
          });
    
    - name: Notify deployment success
      run: |
        echo "🚀 Deployment to ${{ steps.env.outputs.environment }} completed!"
        echo "URL: ${{ steps.url.outputs.url }}"
        echo "Branch: ${{ steps.env.outputs.branch }}"
        echo "Commit: ${{ github.sha }}"

  cleanup:
    runs-on: ubuntu-latest
    if: always()
    needs: deploy
    
    steps:
    - name: Clean up old artifacts
      uses: actions/github-script@v7
      with:
        script: |
          const artifacts = await github.rest.actions.listWorkflowRunArtifacts({
            owner: context.repo.owner,
            repo: context.repo.repo,
            run_id: context.runId
          });
          
          for (const artifact of artifacts.data.artifacts) {
            if (artifact.created_at < new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)) {
              await github.rest.actions.deleteArtifact({
                owner: context.repo.owner,
                repo: context.repo.repo,
                artifact_id: artifact.id
              });
            }
          }