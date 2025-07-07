# organization_idの定義
variable "supabase_organization_id" {
  description = "Supabase Organization ID"
  type        = string
}
# database_passの定義
variable "supabase_database_password" {
  description = "Supabase Database password"
  type        = string
  sensitive   = true
}
# アクセストークンを定義する変数
variable "supabase_access_token" {
  description = "Your Supabase Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "Your GitHub Personal Access Token"
  type        = string
  sensitive   = true
}