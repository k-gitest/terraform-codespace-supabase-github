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

#env:
#  NODE_VERSION: '${node_version}'
#  CLOUDFLARE_PROJECT_NAME: '${cloudflare_project_name}'
#  CLOUDFLARE_ACCOUNT_ID: '${cloudflare_account_id}'

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: $${{ github.event.workflow_run.conclusion == "success" || github.event_name == "workflow_dispatch" }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

      # ciでビルドしたアーティファクトをダウンロードして使用する場合
    - name: Download build artifact from CI
      uses: dawidd6/action-download-artifact@v6
      with:
        # workflow_runイベントからトリガー元のワークフロー実行IDを取得
        run_id: $${{ github.event.workflow_run.id }}
        name: build-artifact # CI側で付けたアーティファ-クト名
        path: ./dist # ダウンロード先のパス

    # artifactを使用する場合 必要なくなる ↓↓↓
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: "${node_version}"
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build application
      run: npm run build
    # ここまで必要なくなる ↑↑↑
    
    # environmentの判定を行い、branchとenvironmentを設定
    # workflow_dispatchイベントの場合は、入力されたenvironmentを使用し、branchは実行時の現在のブランチを使用
    # workflow_runイベントの場合は、CIのブランチに応じて環境を設定
    # mainブランチならproduction、developブランチならstaging、それ以外はpreview環境とする
    - name: Determine deployment environment
      id: env # 以降のステップでこのIDを参照
      run: | 
        if [[ "$${{ github.event_name }}" == "workflow_dispatch" ]]; then
          echo "environment=$${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
          echo "branch=$${{ github.ref_name }}" >> $GITHUB_OUTPUT
        elif [[ "$${{ github.event.workflow_run.head_branch }}" == "main" ]]; then
          echo "environment=production" >> $GITHUB_OUTPUT
          echo "branch=main" >> $GITHUB_OUTPUT
        elif [[ "$${{ github.event.workflow_run.head_branch }}" == "develop" ]]; then
          echo "environment=develop" >> $GITHUB_OUTPUT
          echo "branch=develop" >> $GITHUB_OUTPUT
        else
          echo "environment=preview" >> $GITHUB_OUTPUT
          echo "branch=preview" >> $GITHUB_OUTPUT
        fi
    
    - name: Deploy to Cloudflare Pages
      uses: cloudflare/pages-action@v1
      with:
        apiToken: $${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: $${{ env.CLOUDFLARE_ACCOUNT_ID }}
        projectName: $${{ env.CLOUDFLARE_PROJECT_NAME }}
        directory: dist
        gitHubToken: $${{ secrets.GITHUB_TOKEN }}
        branch: $${{ steps.env.outputs.branch }}
    
    # 環境に応じてデプロイURLを設定
    # cloudflareはブランチ名がサブドメインになるため、環境名とブランチ名を統一
    - name: Set deployment URL
      id: url
      run: |
        if [[ "$${{ steps.env.outputs.environment }}" == "production" ]]; then
          echo "url=https://$${CLOUDFLARE_PROJECT_NAME}.pages.dev" >> $GITHUB_OUTPUT
        elif [[ "$${{ steps.env.outputs.environment }}" == "develop" ]]; then
          echo "url=https://develop.$${CLOUDFLARE_PROJECT_NAME}.pages.dev" >> $GITHUB_OUTPUT
        else
          echo "url=https://preview.$${CLOUDFLARE_PROJECT_NAME}.pages.dev" >> $GITHUB_OUTPUT
        fi
    
    # Deployments APIを使用して、デプロイメントの記録を作成
    # githubリポジトリの右側にデプロイ状態が表示される
    # createDeploymentが初期状態、createDeploymentStatusで状態を更新
    - name: Create deployment record
      uses: actions/github-script@v7
      with:
        script: |
          const deployment = await github.rest.repos.createDeployment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            ref: context.sha,
            environment: '$${{ steps.env.outputs.environment }}',
            description: 'Deploy to Cloudflare Pages ($${{ steps.env.outputs.environment }})',
            required_contexts: []
          });
          
          await github.rest.repos.createDeploymentStatus({
            owner: context.repo.owner,
            repo: context.repo.repo,
            deployment_id: deployment.data.id,
            state: 'success',
            environment_url: '$${{ steps.url.outputs.url }}',
            description: 'Deployment to $${{ steps.env.outputs.environment }} successful'
          });
    
    # デプロイ成功の場合actionsログに出力
    - name: Notify deployment success
      run: |
        echo "🚀 Deployment to $${{ steps.env.outputs.environment }} completed!"
        echo "URL: $${{ steps.url.outputs.url }}"
        echo "Branch: $${{ steps.env.outputs.branch }}"
        echo "Commit: $${{ github.sha }}"

  # 使用したアーティファクトを削除するcleanupジョブ
  # アーティファクト作成時にretention-daysを設定している場合はなくてもよい
  # 手動でアーティファクトを削除したい場合やアーティファクトの保存期間を短くしたい場合は必要
  cleanup:
    runs-on: ubuntu-latest
    if: always() # deployジョブが成功・失敗に関わらず実行
    needs: deploy # deployジョブの後に実行
    
    steps:
    - name: Clean up old artifacts
      uses: actions/github-script@v7
      with:
        script: | # run_idに紐づくワークフローからアーティファクト一覧を取得し、7日以上前に作成されたものを削除
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