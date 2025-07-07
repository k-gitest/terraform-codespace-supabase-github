output "repository_name" {
  description = "作成されたGitHubリポジトリの名前"
  value       = github_repository.this.name
}

output "repository_id" {
  description = "作成されたGitHubリポジトリのID"
  value       = github_repository.this.id
}

output "html_url" {
  description = "GitHubリポジトリのWeb URL"
  value       = github_repository.this.html_url
}

output "ssh_clone_url" {
  description = "リポジトリのSSHクローンURL"
  value       = github_repository.this.ssh_clone_url
}

output "http_clone_url" {
  description = "リポジトリのHTTPSクローンURL"
  value       = github_repository.this.http_clone_url
}

/* githubプロバイダーのdefaut branchは非推奨になったため、コメントアウト
output "default_branch" {
  description = "リポジトリのデフォルトブランチ名"
  value       = github_repository.this.default_branch
}
*/

# 必要に応じて、他の属性も追加
# output "full_name" {
#   description = "リポジトリのフルネーム（例: owner/repo-name）"
#   value       = github_repository.this.full_name
# }