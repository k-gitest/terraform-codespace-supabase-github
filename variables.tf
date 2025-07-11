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
