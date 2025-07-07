# modules/github-devcontainer-file/variables.tf

variable "repository_name" {
  description = "Name of the GitHub repository."
  type        = string
}

variable "branch_name" {
  description = "Name of the branch to commit the file to."
  type        = string
  default     = "main"
}

variable "devcontainer_name" {
  description = "Name for the Dev Container."
  type        = string
  default     = "Dev Container"
}

variable "devcontainer_image" {
  description = "Docker image for the Dev Container."
  type        = string
  default     = "mcr.microsoft.com/devcontainers/universal:2-nodejs-20"
}

variable "nodejs_version" {
  description = "Node.js version for the Dev Container."
  type        = string
  default     = "20"
}

variable "forward_ports" {
  description = "List of ports to forward from the Dev Container."
  type        = list(number)
  default     = [5173]
}

variable "post_create_command" {
  description = "Command to run after the container is created."
  type        = string
  default     = "npm install"
}

variable "vscode_extensions" {
  description = "List of VS Code extensions to install in the Dev Container."
  type        = list(string)
  default = [
    "ms-vscode.remote-explorer",
    "ms-vscode-remote.remote-containers",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "Prisma.prisma",
    "streetsidesoftware.code-spell-checker",
    "denoland.vscode-deno"
  ]
}

variable "vscode_settings" {
  description = "Map of VS Code settings for the Dev Container."
  type        = any 
  default = {
    "terminal.integrated.defaultProfile.linux" = "bash"
    "editor.formatOnSave" = true
    "eslint.validate" = [
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact"
    ]
    # ここからDeno関連のVS Code設定を追加
    "deno.enable": true,
    "deno.lint": true,
    "deno.unstable": true, # 必要であれば
    "typescript.enablePromptUseWorkspaceTsdk": false,
    "typescript.tsdk": "node_modules/typescript/lib",
    "deno.suggest.imports.hosts": {
      "https://deno.land/x/": true,
      "https://raw.githubusercontent.com/": true
    },
    "[typescript]": {
      "editor.defaultFormatter": "denoland.vscode-deno"
    },
    "[typescriptreact]": {
      "editor.defaultFormatter": "denoland.vscode-deno"
    }
  }
}

variable "remote_user" {
  description = "User to use inside the Dev Container."
  type        = string
  default     = "node"
}

variable "commit_message" {
  description = "Commit message for the .devcontainer file."
  type        = string
  default     = "feat: Add .devcontainer/devcontainer.json"
}

variable "commit_author" {
  description = "Author name for the commit."
  type        = string
  default     = "Terraform Bot"
}

variable "commit_email" {
  description = "Author email for the commit."
  type        = string
  default     = "terraform@example.com"
}