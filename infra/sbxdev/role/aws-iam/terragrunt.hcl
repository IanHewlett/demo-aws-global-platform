include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  aws_assume_role = "Terraform"
  module_source   = "demo-module-aws-iam"
  module_version  = "0.0.1"
}

inputs = {
  aws_account_id = include.root.locals.aws_account_id
}

terraform {
  source = "git@github.com:${include.root.locals.github_org}/${local.module_source}.git?ref=${local.module_version}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${include.root.locals.default_region}"

  assume_role {
    role_arn = "arn:aws:iam::${include.root.locals.aws_account_id}:role/${local.aws_assume_role}"
  }

  default_tags {
    tags = {
      Environment      = "${include.root.locals.environment}"
      ReleaseVersion   = "${local.module_source}:${local.module_version}"
      ProvisionedBy    = "Terraform"
    }
  }
}
EOF
}
