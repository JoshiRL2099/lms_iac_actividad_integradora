terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}

data "vault_kv_secret_v2" "aws_creds" {
  mount = "secret"
  name  = "aws"
}
