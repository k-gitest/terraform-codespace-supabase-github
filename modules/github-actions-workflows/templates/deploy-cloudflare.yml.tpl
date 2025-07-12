name: Deploy to Cloudflare Pages

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  NODE_VERSION: '${node_version}'
  CLOUDFLARE_PROJECT_NAME: '${cloudflare_project_name}'
  CLOUDFLARE_ACCOUNT_ID: '${cloudflare_account_id}'

jobs:
  build:
    runs-on: ubuntu-latest
    
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
    
    - name: Upload build artifacts
      uses: actions/upload-artifact@v4
      with:
        name: build-files
        path: dist/
        retention-days: 1

  deploy-preview:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Download build artifacts
      uses: actions/download-artifact@v4
      with:
        name: build-files
        path: dist/
    
    - name: Deploy to Cloudflare Pages (Preview)
      uses: cloudflare/pages-action@v1
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ env.CLOUDFLARE_ACCOUNT_ID }}
        projectName: ${{ env.CLOUDFLARE_PROJECT_NAME }}
        directory: dist
        gitHubToken: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Comment PR with preview URL
      uses: actions/github-script@v7
      with:
        script: |
          const { data: deployments } = await github.rest.repos.listDeployments({
            owner: context.repo.owner,
            repo: context.repo.repo,
            ref: context.payload.pull_request.head.sha
          });
          
          if (deployments.length > 0) {
            const previewUrl = `https://${deployments[0].sha}.${process.env.CLOUDFLARE_PROJECT_NAME}.pages.dev`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `🚀 **Preview deployed!**\n\n[Visit Preview](${previewUrl})`
            });
          }

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Download build artifacts
      uses: actions/download-artifact@v4
      with:
        name: build-files
        path: dist/
    
    - name: Deploy to Cloudflare Pages (Staging)
      uses: cloudflare/pages-action@v1
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ env.CLOUDFLARE_ACCOUNT_ID }}
        projectName: ${{ env.CLOUDFLARE_PROJECT_NAME }}
        directory: dist
        gitHubToken: ${{ secrets.GITHUB_TOKEN }}
        branch: staging
    
    - name: Notify staging deployment
      run: |
        echo "🚀 Staging deployment completed!"
        echo "Staging URL: https://staging.${env.CLOUDFLARE_PROJECT_NAME}.pages.dev"

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Download build artifacts
      uses: actions/download-artifact@v4
      with:
        name: build-files
        path: dist/
    
    - name: Deploy to Cloudflare Pages (Production)
      uses: cloudflare/pages-action@v1
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ env.CLOUDFLARE_ACCOUNT_ID }}
        projectName: ${{ env.CLOUDFLARE_PROJECT_NAME }}
        directory: dist
        gitHubToken: ${{ secrets.GITHUB_TOKEN }}
        branch: main
    
    - name: Notify production deployment
      run: |
        echo "🚀 Production deployment completed successfully!"
        echo "Production URL: https://${env.CLOUDFLARE_PROJECT_NAME}.pages.dev"
    
    - name: Create deployment status
      uses: actions/github-script@v7
      with:
        script: |
          github.rest.repos.createDeploymentStatus({
            owner: context.repo.owner,
            repo: context.repo.repo,
            deployment_id: context.payload.deployment.id,
            state: 'success',
            environment_url: `https://${process.env.CLOUDFLARE_PROJECT_NAME}.pages.dev`,
            description: 'Deployment to Cloudflare Pages successful'
          });

  cleanup:
    needs: [deploy-preview, deploy-staging, deploy-production]
    runs-on: ubuntu-latest
    if: always()
    
    steps:
    - name: Clean up artifacts
      uses: actions/github-script@v7
      with:
        script: |
          const artifacts = await github.rest.actions.listWorkflowRunArtifacts({
            owner: context.repo.owner,
            repo: context.repo.repo,
            run_id: context.runId
          });
          
          for (const artifact of artifacts.data.artifacts) {
            await github.rest.actions.deleteArtifact({
              owner: context.repo.owner,
              repo: context.repo.repo,
              artifact_id: artifact.id
            });
          }