variable "repository_name" {
  description = "GitHubリポジトリ名"
  type        = string
}

variable "default_branch" {
  description = "デフォルトブランチ名"
  type        = string
  default     = "main"
}

variable "node_version" {
  description = "Node.jsのバージョン"
  type        = string
  default     = "20"
}

# Supabase関連変数
variable "supabase_project_id" {
  description = "SupabaseプロジェクトのID"
  type        = string
}

variable "supabase_access_token" {
  description = "Supabase Personal Access Token"
  type        = string
  sensitive   = true
}

variable "supabase_db_password" {
  description = "Supabaseデータベースのパスワード"
  type        = string
  sensitive   = true
}

variable "supabase_db_url" {
  description = "SupabaseデータベースのURL"
  type        = string
  sensitive   = true
}

variable "supabase_url" {
  description = "SupabaseプロジェクトのURL"
  type        = string
}

variable "supabase_anon_key" {
  description = "Supabaseの匿名キー"
  type        = string
  sensitive   = true
}

# Cloudflare関連変数
variable "cloudflare_project_name" {
  description = "Cloudflare Pagesプロジェクト名"
  type        = string
}

variable "cloudflare_account_id" {
  description = "CloudflareアカウントID"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare APIトークン"
  type        = string
  sensitive   = true
}

# GitHub関連変数
variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

# オプション設定
variable "enable_ci_cd_workflow" {
  description = "CI/CDワークフローを有効にするか"
  type        = bool
  default     = true
}

variable "enable_supabase_workflow" {
  description = "Supabase管理ワークフローを有効にするか"
  type        = bool
  default     = true
}

variable "enable_cloudflare_workflow" {
  description = "Cloudflareデプロイワークフローを有効にするか"
  type        = bool
  default     = true
}

/*
variable "build_command" {
  description = "ビルドコマンド"
  type        = string
  default     = "npm run build"
}


variable "build_directory" {
  description = "ビルド出力ディレクトリ"
  type        = string
  default     = "dist"
}

variable "test_command" {
  description = "テストコマンド"
  type        = string
  default     = "npm run test"
}

variable "lint_command" {
  description = "リントコマンド"
  type        = string
  default     = "npm run lint"
}

variable "type_check_command" {
  description = "型チェックコマンド"
  type        = string
  default     = "npm run type-check"
}
*/