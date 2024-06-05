locals {
  role_vars      = read_terragrunt_config(find_in_parent_folders("role.hcl"))
  project_name   = local.role_vars.locals.project_name
  environment    = local.role_vars.locals.role
  github_org     = local.role_vars.locals.github_org
  vault_addr     = local.role_vars.locals.vault_addr
  aws_account_id = local.role_vars.locals.aws_account_id
  default_region = "us-east-2"
}

generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  cloud {
    organization = "ianwhewlett"

    workspaces {
      name = "${local.project_name}-${basename(get_terragrunt_dir())}-${local.environment}"
    }
  }
}
EOF
}
