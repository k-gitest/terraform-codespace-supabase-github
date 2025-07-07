output "project_id" {
  description = "The ID of the Supabase project"
  value       = supabase_project.this.id
}

output "project_url" {
  description = "The URL of the Supabase project"
  value       = "https://${supabase_project.this.id}.supabase.co"
}

output "project_name" {
  description = "The name of the Supabase project"
  value       = supabase_project.this.name
}