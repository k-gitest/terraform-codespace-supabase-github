variable "cloudflare_account_id" {
  description = "Your Cloudflare Account ID."
  type        = string
}

variable "project_name" {
  description = "The name of the Cloudflare Pages project."
  type        = string
}

variable "production_branch" {
  description = "The production branch name for the Cloudflare Pages project. This is a formal requirement and can be overridden by later CLI deployments."
  type        = string
  default     = "main" # 一般的なデフォルト値
}