terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0" # 使用したいバージョンを指定
    }
  }
}

resource "github_repository_file" "devcontainer_json" {
  repository          = var.repository_name
  branch              = var.branch_name
  file                = ".devcontainer/devcontainer.json"
  content             = <<EOF
{
  "name": "${var.devcontainer_name}",
  "image": "${var.devcontainer_image}",
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "${var.nodejs_version}"
    },
    "ghcr.io/devcontainers/features/deno:1": {
      "version": "latest"
    }
  },
  "forwardPorts": ${jsonencode(var.forward_ports)},
  "postCreateCommand": "${var.post_create_command}",
  "customizations": {
    "vscode": {
      "extensions": ${jsonencode(var.vscode_extensions)},
      "settings": ${jsonencode(var.vscode_settings)}
    }
  },
  "remoteUser": "${var.remote_user}"
}
EOF
  commit_message      = var.commit_message
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true
}
