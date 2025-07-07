variable "organization_id" {
  description = "Supabase Organization ID"
  type        = string
}

variable "project_name" {
  description = "Name of the Supabase project"
  type        = string
}

variable "database_password" {
  description = "Supabase Database Password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region where the Supabase project will be deployed"
  type        = string
  default     = "ap-northeast-1"
}

# Free Plan の場合はこの変数を削除またはコメントアウト
# variable "instance_size" {
#   description = "Instance size for the Supabase project"
#   type        = string
#   default     = "micro"
# }