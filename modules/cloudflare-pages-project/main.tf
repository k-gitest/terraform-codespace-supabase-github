terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0" # 最新の安定バージョンを使用
    }
  }
}

resource "cloudflare_pages_project" "this" {
  account_id      = var.cloudflare_account_id
  name            = var.project_name
  production_branch = var.production_branch

  # GitHub 連携の「source」ブロックは完全に省略します。
  # これにより、Terraform はデプロイ方法を管理しません。
  # deployment_configs ブロックも省略し、デフォルト設定またはCLIからの上書きに任せます。
}