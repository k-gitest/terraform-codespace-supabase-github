# ---------------------------------------------
# モジュールの呼び出し
# ---------------------------------------------
module "my_supabase_project" {
  source = "./modules/supabase-project" # ローカルモジュールのパスを指定

  # モジュールに渡す入力変数
  organization_id   = var.supabase_organization_id
  project_name      = "my-awesome-supabase-project"
  database_password = var.supabase_database_password
  region            = "ap-northeast-1"
  # instance_size   = "micro" # Free Planの場合はこの行をコメントアウト
}

# モジュールからの出力値を受け取る
output "provisioned_project_id" {
  description = "The ID of the provisioned Supabase project"
  value       = module.my_supabase_project.project_id
}

output "provisioned_project_url" {
  description = "The URL of the provisioned Supabase project"
  value       = module.my_supabase_project.project_url
}

# github_repositoryのモジュールを呼び出す
module "my_github_repository" {
  source = "./modules/github-repository" # ローカルモジュールのパス

  repository_name = "supabase-spa-app"
  description     = "This is my awesome repository"
  visibility      = "private" # または "private"
  has_issues      = true      # イシューを有効にする
  has_wiki        = false     # ウィキを無効にする
  has_projects    = false     # プロジェクトを無効にする
  auto_init       = true      # リポジトリを自動的に初期化する
}
# GitHubリポジトリの出力値を受け取る
output "github_repository_url" {
  description = "The URL of the created GitHub repository"
  value       = module.my_github_repository.html_url
}
output "github_repository_name" {
  description = "The name of the created GitHub repository"
  value       = module.my_github_repository.repository_name
}

# .devcontainer/devcontainer.json を追加するモジュールを呼び出す
module "devcontainer_setup" {
  source = "./modules/github-devcontainer-file"

  repository_name = module.my_github_repository.repository_name
  #branch_name     = github_repository.my_dev_repo.default_branch # もし default_branch が取得できるなら
  # もし github_repository.my_dev_repo.default_branch がエラーになる場合、
  # 以下のように直接文字列で指定してもOK
  branch_name = "main"

  # 必要に応じて、モジュール内の変数をオーバーライド
  # nodejs_version = "18"
  # forward_ports  = [3000, 5173]
  # devcontainer_name = "My Custom App Dev"
}

# Cloudflare Pages プロジェクトの作成
module "frontend_pages_project" {
  source = "./modules/cloudflare-pages-project"

  cloudflare_account_id = var.cloudflare_account_id
  project_name          = "my-app-frontend" # 作成したいPagesプロジェクトの名前
  production_branch     = "main"            # ここで上書きも可能
}

# 必要に応じて、別のワーカーモジュールなどを追加
# module "backend_worker" {
#   source = "./modules/cloudflare-worker"
#   # ...
# }

output "frontend_pages_url" {
  description = "The URL of the deployed Cloudflare Pages frontend."
  value       = module.frontend_pages_project.project_url
}

output "frontend_pages_name" {
  description = "The name of the Cloudflare Pages project."
  value       = module.frontend_pages_project.project_name
}

# GitHub Actions ワークフロー
module "github_actions_workflows" {
  source = "./modules/github-actions-workflows"

  repository_name = module.github_repository.name
  default_branch  = var.github_default_branch
  node_version    = var.node_version

  # Supabase設定
  supabase_project_id   = module.supabase_project.project_id
  supabase_access_token = var.supabase_access_token
  supabase_db_password  = var.supabase_database_password
  supabase_db_url       = module.supabase_project.database_url
  supabase_url          = module.supabase_project.api_url
  supabase_anon_key     = module.supabase_project.anon_key

  # Cloudflare設定
  cloudflare_project_name = module.cloudflare_pages.project_name
  cloudflare_account_id   = var.cloudflare_account_id
  cloudflare_api_token    = var.cloudflare_api_token

  # GitHub設定
  github_token = var.github_token

  # ビルド設定
  build_command      = var.build_command
  build_directory    = var.build_directory
  test_command       = var.test_command
  lint_command       = var.lint_command
  type_check_command = var.type_check_command

  # ワークフロー有効化設定
  enable_ci_cd_workflow      = var.enable_ci_cd_workflow
  enable_supabase_workflow   = var.enable_supabase_workflow
  enable_cloudflare_workflow = var.enable_cloudflare_workflow

  depends_on = [
    module.github_repository,
    module.supabase_project,
    module.cloudflare_pages
  ]
}
