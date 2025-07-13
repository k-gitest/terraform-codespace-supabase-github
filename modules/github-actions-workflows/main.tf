terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0" # 使用したいバージョンを指定
    }
  }
}

# CI/CDワークフロー
resource "github_repository_file" "ci_cd_workflow" {
  count      = var.enable_ci_cd_workflow ? 1 : 0
  repository = var.repository_name
  branch     = var.default_branch
  file       = ".github/workflows/ci-cd.yml"
  content = templatefile("${path.module}/templates/ci.yml.tpl", {
    supabase_project_id     = var.supabase_project_id
    cloudflare_project_name = var.cloudflare_project_name
    node_version            = var.node_version
    supabase_db_url         = var.supabase_db_url
    #build_command           = var.build_command
    #build_directory         = var.build_directory
    #test_command            = var.test_command
    #lint_command            = var.lint_command
    #type_check_command      = var.type_check_command
  })
  commit_message      = "Add CI/CD workflow"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Supabase管理ワークフロー
resource "github_repository_file" "supabase_workflow" {
  count      = var.enable_supabase_workflow ? 1 : 0
  repository = var.repository_name
  branch     = var.default_branch
  file       = ".github/workflows/supabase.yml"
  content = templatefile("${path.module}/templates/deploy-supabase.yml.tpl", {
    supabase_project_id = var.supabase_project_id
    supabase_db_url     = var.supabase_db_url
  })
  commit_message      = "Add Supabase management workflow"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Cloudflare Pages デプロイワークフロー
resource "github_repository_file" "cloudflare_workflow" {
  count      = var.enable_cloudflare_workflow ? 1 : 0
  repository = var.repository_name
  branch     = var.default_branch
  file       = ".github/workflows/deploy-cloudflare.yml"
  content = templatefile("${path.module}/templates/cd.yml.tpl", {
    cloudflare_project_name = var.cloudflare_project_name
    cloudflare_account_id   = var.cloudflare_account_id
    node_version            = var.node_version
    #build_command           = var.build_command
    #build_directory         = var.build_directory
  })
  commit_message      = "Add Cloudflare Pages deployment workflow"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# GitHub Actions シークレット
resource "github_actions_secret" "supabase_access_token" {
  repository      = var.repository_name
  secret_name     = "SUPABASE_ACCESS_TOKEN"
  plaintext_value = var.supabase_access_token
}

resource "github_actions_secret" "supabase_db_password" {
  repository      = var.repository_name
  secret_name     = "SUPABASE_DB_PASSWORD"
  plaintext_value = var.supabase_db_password
}

resource "github_actions_secret" "cloudflare_api_token" {
  repository      = var.repository_name
  secret_name     = "CLOUDFLARE_API_TOKEN"
  plaintext_value = var.cloudflare_api_token
}

resource "github_actions_secret" "supabase_url" {
  repository      = var.repository_name
  secret_name     = "SUPABASE_URL"
  plaintext_value = var.supabase_url
}

resource "github_actions_secret" "supabase_anon_key" {
  repository      = var.repository_name
  secret_name     = "SUPABASE_ANON_KEY"
  plaintext_value = var.supabase_anon_key
}

# GitHub Actions 変数
resource "github_actions_variable" "supabase_project_id" {
  repository    = var.repository_name
  variable_name = "SUPABASE_PROJECT_ID"
  value         = var.supabase_project_id
}

resource "github_actions_variable" "cloudflare_project_name" {
  repository    = var.repository_name
  variable_name = "CLOUDFLARE_PROJECT_NAME"
  value         = var.cloudflare_project_name
}

resource "github_actions_variable" "cloudflare_account_id" {
  repository    = var.repository_name
  variable_name = "CLOUDFLARE_ACCOUNT_ID"
  value         = var.cloudflare_account_id
}

resource "github_actions_variable" "node_version" {
  repository    = var.repository_name
  variable_name = "NODE_VERSION"
  value         = var.node_version
}
