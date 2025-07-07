terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase" # 正しいソースアドレスを明示的に指定
      version = "~> 1.0"            # 使用するバージョン要件も指定
    }
  }
}

# このモジュールがプロビジョニングするSupabaseプロジェクトのリソース
resource "supabase_project" "this" {
  organization_id   = var.organization_id
  name              = var.project_name
  database_password = var.database_password
  region            = var.region
  # instance_size   = var.instance_size # Free Planの場合はコメントアウト
}