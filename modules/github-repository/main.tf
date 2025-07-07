terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0" # 使用したいバージョンを指定
    }
  }
}

# GitHubリポジトリリソースの定義
resource "github_repository" "this" {
  name             = var.repository_name
  description      = var.description
  visibility       = var.visibility
  has_issues       = var.has_issues
  has_wiki         = var.has_wiki
  has_projects     = var.has_projects
  auto_init        =  var.auto_init
}