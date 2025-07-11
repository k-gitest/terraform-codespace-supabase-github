output "project_id" {
  description = "The ID of the created Cloudflare Pages project."
  value       = cloudflare_pages_project.this.id
}

output "project_name" {
  description = "The name of the created Cloudflare Pages project."
  value       = cloudflare_pages_project.this.name
}

output "project_url" {
  description = "The URL of the created Cloudflare Pages project."
  value       = cloudflare_pages_project.this.domains[0] # 最初のドメインを返す
}