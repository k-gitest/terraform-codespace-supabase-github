name: Supabase Management

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'supabase/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'supabase/**'
  workflow_dispatch:

env:
  SUPABASE_PROJECT_ID: '${supabase_project_id}'
  SUPABASE_DB_URL: '${supabase_db_url}'

jobs:
  validate-migrations:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Supabase CLI
      uses: supabase/setup-cli@v1
      with:
        version: latest
    
    - name: Validate migrations
      run: |
        supabase db lint
        supabase db diff --schema public
      env:
        SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

  deploy-migrations:
    needs: validate-migrations
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Supabase CLI
      uses: supabase/setup-cli@v1
      with:
        version: latest
    
    - name: Link to Supabase project
      run: |
        supabase link --project-ref ${{ env.SUPABASE_PROJECT_ID }}
      env:
        SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
    
    - name: Deploy database migrations
      run: |
        supabase db push
      env:
        SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
    
    - name: Generate TypeScript types
      run: |
        supabase gen types typescript --project-id ${{ env.SUPABASE_PROJECT_ID }} > types/supabase.ts
      env:
        SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
    
    - name: Commit generated types
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add types/supabase.ts
        git diff --staged --quiet || git commit -m "Update Supabase types"
        git push
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  generate-docs:
    needs: deploy-migrations
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Supabase CLI
      uses: supabase/setup-cli@v1
      with:
        version: latest
    
    - name: Generate API documentation
      run: |
        supabase gen docs --project-id ${{ env.SUPABASE_PROJECT_ID }} > docs/api.md
      env:
        SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
    
    - name: Commit generated documentation
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add docs/api.md
        git diff --staged --quiet || git commit -m "Update API documentation"
        git push
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}