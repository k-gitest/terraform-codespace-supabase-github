output "ci_cd_workflow_file" {
  description = "CI/CDワークフローファイルのパス"
  value       = var.enable_ci_cd_workflow ? github_repository_file.ci_cd_workflow[0].file : null
}

output "supabase_workflow_file" {
  description = "Supabase管理ワークフローファイルのパス"
  value       = var.enable_supabase_workflow ? github_repository_file.supabase_workflow[0].file : null
}

output "cloudflare_workflow_file" {
  description = "Cloudflareデプロイワークフローファイルのパス"
  value       = var.enable_cloudflare_workflow ? github_repository_file.cloudflare_workflow[0].file : null
}

output "github_actions_secrets" {
  description = "作成されたGitHub Actionsシークレット"
  value = {
    supabase_access_token = github_actions_secret.supabase_access_token.secret_name
    supabase_db_password  = github_actions_secret.supabase_db_password.secret_name
    cloudflare_api_token  = github_actions_secret.cloudflare_api_token.secret_name
    supabase_url          = github_actions_secret.supabase_url.secret_name
    supabase_anon_key     = github_actions_secret.supabase_anon_key.secret_name
  }
}

output "github_actions_variables" {
  description = "作成されたGitHub Actions変数"
  value = {
    supabase_project_id     = github_actions_variable.supabase_project_id.variable_name
    cloudflare_project_name = github_actions_variable.cloudflare_project_name.variable_name
    cloudflare_account_id   = github_actions_variable.cloudflare_account_id.variable_name
    node_version           = github_actions_variable.node_version.variable_name
  }
}

output "workflow_files_created" {
  description = "作成されたワークフローファイルのリスト"
  value = compact([
    var.enable_ci_cd_workflow ? github_repository_file.ci_cd_workflow[0].file : "",
    var.enable_supabase_workflow ? github_repository_file.supabase_workflow[0].file : "",
    var.enable_cloudflare_workflow ? github_repository_file.cloudflare_workflow[0].file : ""
  ])
}

output "deployment_urls" {
  description = "デプロイメントURL"
  value = {
    production = "https://${var.cloudflare_project_name}.pages.dev"
    staging    = "https://staging.${var.cloudflare_project_name}.pages.dev"
  }
}