name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

#env:
#  NODE_VERSION: "${node_version}"
#  SUPABASE_PROJECT_ID: "${supabase_project_id}"
#  CLOUDFLARE_PROJECT_NAME: "${cloudflare_project_name}"

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "${node_version}"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run type check
        run: npm run type-check

      - name: Run tests
        run: npm run test

      - name: Test build
        run: npm run build

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always() # テストが失敗しても結果はアップロードする
        with:
          name: test-results # テスト結果のアーティファクト名
          path: |
            coverage/
            test-results.xml
          retention-days: 7

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: build-artifact # デプロイ用の成果物であることがわかる名前
          path: dist/
          retention-days: 7
