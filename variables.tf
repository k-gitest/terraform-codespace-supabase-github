# supabase organization_idの定義
variable "supabase_organization_id" {
  description = "Supabase Organization ID"
  type        = string
}
# supabase database_passの定義
variable "supabase_database_password" {
  description = "Supabase Database password"
  type        = string
  sensitive   = true
}
# supabase アクセストークンを定義する変数
variable "supabase_access_token" {
  description = "Your Supabase Personal Access Token"
  type        = string
  sensitive   = true
}

# GitHubトークンの定義
variable "github_token" {
  description = "Your GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

# GitHub関連の変数
variable "github_default_branch" {
  description = "GitHubリポジトリのデフォルトブランチ名"
  type        = string
  default     = "main"
}

# Node.js関連の変数
variable "node_version" {
  description = "使用するNode.jsのバージョン"
  type        = string
  default     = "18"
}

# cloudflare_pages_project モジュールの変数定義
variable "cloudflare_account_id" {
  description = "Your Cloudflare Account ID."
  type        = string
  sensitive = false
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token with Pages/Workers permissions."
  type        = string
  sensitive   = true # 機密情報として扱う
}

# ビルド設定関連の変数
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
  default     = "npm test"
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

# ワークフロー有効化設定
variable "enable_ci_cd_workflow" {
  description = "CI/CDワークフローを有効にするかどうか"
  type        = bool
  default     = true
}

variable "enable_supabase_workflow" {
  description = "Supabaseワークフローを有効にするかどうか"
  type        = bool
  default     = true
}

variable "enable_cloudflare_workflow" {
  description = "Cloudflareワークフローを有効にするかどうか"
  type        = bool
  default     = true
}