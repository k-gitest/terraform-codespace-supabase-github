# Supabaseプロジェクトのリソース定義
/*
resource "supabase_project" "my_project" {
  organization_id   = var.supabase_organization_id # あなたのSupabase組織ID
  name              = "my-awesome-supabase-project"
  database_password = var.supabase_database_password # 強力なパスワードを設定
  region            = "ap-northeast-1" # プロジェクトをデプロイするリージョン
}
*/

# プロジェクトのIDを出力する
/*
output "project_id" {
  description = "The ID of the Supabase project"
  value       = supabase_project.my_project.id
}
*/

# プロジェクトのURLを出力する
/*
output "project_url" {
  description = "The URL of the Supabase project"
  value       = "https://${supabase_project.my_project.id}.supabase.co"
}
*/

# ---------------------------------------------
# ここからがモジュールの呼び出し
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

# --- movedブロックの追加 ---
# 既存のsupabase_project.my_projectをmodule.my_supabase_project.supabase_project.thisに移動
/*
moved {
  from = supabase_project.my_project
  to   = module.my_supabase_project.supabase_project.this
}
*/

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
  has_issues      = true # イシューを有効にする
  has_wiki        = false # ウィキを無効にする
  has_projects    = false # プロジェクトを無効にする
  auto_init       = true # リポジトリを自動的に初期化する
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
   branch_name     = "main"

  # 必要に応じて、モジュール内の変数をオーバーライド
  # nodejs_version = "18"
  # forward_ports  = [3000, 5173]
  # devcontainer_name = "My Custom App Dev"
}