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

output "database_url" {
  description = "The PostgreSQL database connection URL for the Supabase project."
  # 例: postgresql://[ユーザー名]:[パスワード]@[ホスト]:[ポート]/[データベース名]
  # Supabaseの場合: postgresql://postgres:[あなたのDBパスワード]@db.[プロジェクトID].supabase.co:5432/postgres
  # `supabase_project.this.id` または `supabase_project.main.id` を使ってIDを取得
  value       = "postgresql://postgres:${var.database_password}@db.${supabase_project.this.id}.supabase.co:5432/postgres" # または `supabase_project.main.id`
  sensitive   = true # パスワードが含まれるため、必ず `sensitive = true` に設定！
}

output "anon_key" {
  description = "The anonymous key for the Supabase project (Placeholder - copy actual key from Supabase dashboard!)"
  # ここに一時的に適当な文字列を入れます
  # ただし、これはダミー値であり、実際のSupabaseプロジェクトのキーとは異なります！
  value     = "dummy_anon_key_placeholder_for_terraform_validation"
  sensitive = true # キーなので sensitive は忘れずに
}