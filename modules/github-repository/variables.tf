# 変数定義
variable "repository_name" {
  description = "GitHubリポジトリの名前"
  type        = string
}

variable "description" {
  description = "GitHubリポジトリの説明"
  type        = string
  default     = null # 省略可能にする場合はnullをデフォルトに設定
}

variable "visibility" {
  description = "リポジトリの可視性 (public または private)"
  type        = string
  default     = "private" # デフォルト値を設定することも可能
  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "visibilityは 'public' または 'private' である必要があります。"
  }
}

variable "has_issues" {
  description = "イシューを有効にするかどうか"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Wikiを有効にするかどうか"
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "プロジェクトを有効にするかどうか"
  type        = bool
  default     = false
}

variable "default_branch" {
  description = "デフォルトブランチの名前"
  type        = string
  default     = "main"
}

variable "auto_init" {
  description = "リポジトリを自動的に初期化するかどうか"
  type        = bool
  default     = true
}