terraform {
  required_providers {
    supabase = {
      source = "supabase/supabase"
      version = "~> 1.0" # 利用するSupabaseプロバイダーのバージョンを指定
    }
    
    github = {
      source  = "integrations/github"
      version = "~> 5.0" # プロバイダのバージョンを指定
    }
  }

  cloud {
    organization = "sb-terraform" # Terraform Cloudの組織名
    workspaces {
      name = "supabase-terraform" # Terraform Cloudのワークスペース名
    }
  }
}

# Supabaseプロバイダーの設定
provider "supabase" {
  access_token = var.supabase_access_token # Terraform Cloud変数から読み込む
}


provider "github" {
  # GitHubのPersonal Access Token (PAT) を指定
  # 環境変数 GITHUB_TOKEN に設定するのが一般的で安全です
  # access_token = var.github_token
}
