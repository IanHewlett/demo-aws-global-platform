include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  module_source  = "demo-module-vault-pki-root"
  module_version = "0.0.1"
}

inputs = {
  role       = include.root.locals.environment
  vault_addr = include.root.locals.vault_addr
}

terraform {
  source = "git@github.com:${include.root.locals.github_org}/${local.module_source}.git?ref=${local.module_version}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "vault" {
  address = "${include.root.locals.vault_addr}"
  namespace = "admin"
}
EOF
}
