# Supabase プロジェクトのインフラ自動化

Terraform CloudとGitHub Codespacesを使用してSupabaseプロジェクトをコードで管理し、GitHubリポジトリを自動作成するためのテンプレートです。

## 概要

このプロジェクトは、Infrastructure as Code（IaC）の考え方に基づき、Supabaseプロジェクトと、その開発に必要なCodespaces対応GitHubリポジトリの作成・管理を自動化します。 開発者はコードを書くだけで、必要なインフラストラクチャと開発環境が自動的に構築され、Codespacesですぐに開発に取り掛かることができます。

## 使用技術

| 技術 | 用途 | バージョン |
|------|------|------------|
| **Terraform** | インフラストラクチャのコード管理 | >= 1.0 |
| **Terraform Cloud** | 状態管理とチーム協業 | 最新版 |
| **Supabase** | バックエンドサービス | 最新版 |
| **GitHub Codespaces** | クラウド開発環境 | 最新版 |
| **Cloudflare Workers & Pages** | エッジコンピューティング/サーバーレスプラットフォーム | 最新版 |
| **Github Actions** | CI/CDプラットフォーム | 最新版 |

## 機能

### ✨ 主な機能

- **ゼロインストール開発**: ローカルへのTerraform/Docker環境構築が不要
- **ワンクリック開発環境**: Codespacesで即座に開発開始
- **セキュアな機密情報管理**: Terraform Cloudで安全にトークンを管理
- **再現可能なインフラ**: コードベースでのプロジェクト管理
- **自動リポジトリ作成**: GitHubリポジトリの自動生成
- **開発環境の統一**: 開発時に同じ環境を使用
- **デプロイ先の自動準備**: Cloudflareによるエッジ環境のデプロイ先を自動作成
- **テストとデプロイの自動化**: アプリケーションのテストとデプロイの自動化

## 事前準備

### 1. Supabaseアカウントの準備

1. [Supabase](https://supabase.com)でアカウントを作成
2. 組織IDの取得：
   - Supabaseダッシュボードにログイン
   - 左側メニューから「Settings」→「General」
   - 「Organization ID」をコピーして保存

### 2. Supabase Personal Access Tokenの作成

1. Supabaseダッシュボードで右上のアバターをクリック
2. 「Account Settings」→「Access Tokens」
3. 「Generate new token」をクリック
4. トークン名を入力（例：`terraform-access`）
5. 生成されたトークンを**安全な場所に保存**

> ⚠️ **重要**: このトークンは一度しか表示されません。必ず安全な場所に保存してください。

### 3. Terraform Cloudアカウントの設定

1. [Terraform Cloud](https://app.terraform.io)でアカウントを作成
2. 新しい組織を作成（例：`your-company-terraform`）
3. ワークスペースを作成：
   - 「CLI-driven workflow」を選択
   - ワークスペース名を入力（例：`supabase-project`）

### 4. GitHubアカウントの準備

1. [GitHub](https://github.com)アカウントを作成
2. 新しいリポジトリを作成してこのテンプレートをclone

## セットアップ手順

### ステップ1: Codespaceの起動

1. GitHubリポジトリページで「**< > Code**」ボタンをクリック
2. 「**Codespaces**」タブを選択
3. 「**Create codespace on main**」をクリック

Codespaceが起動すると、必要なツールが自動的にインストールされます。

### ステップ2: Terraform Cloudへのログイン

ターミナルで以下を実行：

```bash
terraform login
```

手順：
1. `Do you want to proceed?` → `yes`と入力
2. CUIブラウザが起動したら `q` で閉じる
3. 表示されたURL（`https://app.terraform.io/app/settings/tokens?source=terraform-login`）をコピー
4. 新しいブラウザタブで開く
5. 「**Create an API token**」をクリック
6. 生成されたトークンをコピー
7. ターミナルに戻り、`Token for app.terraform.io:` の後にトークンを貼り付け

### ステップ3: Terraform Cloud変数の設定

Terraform Cloudの Web UIで変数を設定します：

1. [Terraform Cloud](https://app.terraform.io)にログイン
2. 対象のワークスペースに移動
3. 「**Variables**」タブをクリック
4. 以下の変数を追加：

| 変数名 | 値 | カテゴリ | センシティブ | HCL |
|--------|-----|----------|--------------|-----|
| `supabase_access_token` | あなたのSupabaseトークン | Terraform | ✅ | ❌ |
| `supabase_organization_id` | あなたの組織ID | Terraform | ❌ | ❌ |
| `supabase_database_password` | 強力なパスワード | Terraform | ✅ | ❌ |

### ステップ4: 設定ファイルの確認

プロジェクトの設定ファイルを確認・編集します：

#### `variables.tf`の確認
```terraform
variable "supabase_access_token" {
  description = "Supabase Personal Access Token"
  type        = string
  sensitive   = true
}

variable "supabase_organization_id" {
  description = "Supabase Organization ID"
  type        = string
  # 例: "abcd1234-5678-90ef-ghij-klmnopqrstuv"
}

variable "supabase_database_password" {
  description = "データベースパスワード（8文字以上）"
  type        = string
  sensitive   = true
}
```

#### `main.tf`の編集
```terraform
# Supabaseプロジェクトモジュールの呼び出し
module "supabase_project" {
  source = "./modules/supabase-project"
  
  organization_id   = var.supabase_organization_id
  project_name      = "my-awesome-project"
  database_password = var.supabase_database_password
  region           = "ap-northeast-1"
}

# 出力値の定義
output "project_id" {
  description = "作成されたSupabaseプロジェクトのID"
  value       = module.supabase_project.project_id
}

output "project_url" {
  description = "SupabaseプロジェクトのURL"
  value       = module.supabase_project.project_url
}
```

### ステップ5: 初期化とデプロイ

```bash
# Terraform初期化
terraform init

# プランの確認
terraform plan

# デプロイ実行
terraform apply
```

`terraform apply`で `yes` を入力してデプロイを実行します。

### ステップ6: 結果の確認

デプロイが完了すると、以下の出力が表示されます：

```
Outputs:
project_id = "abcdefghijklmnopqrstuvwx"
project_url = "https://abcdefghijklmnopqrstuvwx.supabase.co"
```

出力されたURLをブラウザで開き、新しいSupabaseプロジェクトが作成されていることを確認してください。

## プロジェクト構成

```
project-root/
├── .devcontainer/
│   └── devcontainer.json       # Codespaces環境設定
├── main.tf                     # メインのリソース定義
├── variables.tf                # 変数定義
├── outputs.tf                  # 出力値定義
├── provider.tf                 # プロバイダー設定
└── modules/
    ├── github-actions-workflows/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── templates/
    │       ├── ci.yml.tpl
    │       ├── cd.yml.tpl
    │       └── deploy-supabase.yml.tpl
    ├── cloudflare-pages-project/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── github-repository/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── github-devcontainer-file/
    │   ├── main.tf
    │   └── variables.tf
    └── supabase-project/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## モジュール化について

- **再利用性**: 同じ設定を複数のプロジェクトで使用可能
- **管理性**: 責任範囲を明確にして管理が容易
- **テスト性**: 各モジュールを独立してテスト可能

### モジュールの基本構造

各モジュールは以下のファイルで構成されます：

```
modules/your-module/
├── main.tf      # リソース定義
├── variables.tf # 入力変数
└── outputs.tf   # 出力値
```

### モジュールの呼び出し方

```terraform
module "example" {
  source = "./modules/your-module"
  
  # 変数の値を渡す
  variable_name = var.input_value
}
```

## モジュール移行時のプロバイダーエラー

**エラー**: `Error: Failed to query available provider packages`

**原因**: プロバイダーを確認しても間違っていない場合、モジュールのプロバイダーが定義されていない可能性がある。特にHashiCorp製以外のプロバイダーで起こります

**解決方法**: モジュールの`versions.tfもしくはmain.tf`でプロバイダーを明示的に定義

```terraform
# modules/your-module/versions.tfもしくはmain.tf
terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }
}
```

### 参考資料
- [公式ドキュメント](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

## Terraform で GitHub Actions の `${{...}}` を使用した場合のエラー対応

Terraform の `templatefile()` を使って GitHub Actions のワークフローを `.yml.tpl` として管理する場合、GitHub Actions の構文 `${{ … }}` はそのままではエラーになります。

### 🪲 原因

Terraform のテンプレートエンジンは `.tpl` 内の文字列をパースする際に、`${…}` を自分の変数展開だと誤認識してしまい、以下のようなエラーが発生します：

```
Error: Invalid character; Single quotes are not valid. Use double quotes (") to enclose strings.
```

```
Call to function "templatefile" failed: Missing key/value separator; Expected an equals sign ("=") to mark the beginning of the attribute value.
```

これは、GitHub Actions の `${{ github.xxx }}` が Terraform の `${}` と衝突するためです。

### 🛠️ 対応方法

`.tpl` 内のすべての `${{ … }}` を、Terraform に無視させるために `$${{ … }}` と書きます。

```yaml
# 修正前
if: ${{ github.event.workflow_run.conclusion == "success" }}

# 修正後
if: $${{ github.event.workflow_run.conclusion == "success" }}
```

このように先頭の `$` を重ねることで、Terraform は `${` を自分のものとしてパースせず、出力時には `$` ひとつのままファイルに書き出されます。
   
この方法により、Terraform のテンプレート機能を活用しながら、GitHub Actions の構文を正しく扱うことができます。

## github actionsの権限設定
GitHub Actionsがリポジトリ内のファイルやシークレット、変数を操作できるように、適切な権限を持つPATを生成し、Terraformの実行環境に設定する必要があります。

Fine-grained personal access token を使用してください。

### PATに付与する権限（Repository Permissions）
新しいPATを生成する際、または既存のPATを更新する際に、以下のリポジトリ権限を必ず付与してください。

**Repository Access**:

All repositories または、このプロジェクトのリポジトリを Selected repositories に含める。

**Repository Permissions**:

- Administration: Read and Write
- Contents: Read and Write
- Secrets: Read and Write
- Workflows: Read and Write
- Variables: Read and Write
- Metadata: Read-only (これはデフォルトで付与されることが多いですが、念のため確認)

特に Secrets、Workflows、Variables の Read and Write 権限が重要です。 これらの権限が不足していると、TerraformによるGitHub Actions関連リソースの作成・更新が 403 Resource not accessible エラーで失敗します。

**PATの有効期限**
セキュリティのため、PATの有効期限は必要最低限の期間に設定することをお勧めしますが、CI/CDパイプラインの安定運用を考慮し、定期的な更新を計画してください。

### 403 Resource not accessible by personal access tokenの場合
`403 Resource not accessible by personal access token`
このエラーが出た場合、上記のPAT設定をまず確認することを推奨します。