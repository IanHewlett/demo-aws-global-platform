locals {
  role_vars = read_terragrunt_config(find_in_parent_folders("role.hcl"))
  #aws_assume_role = "platform-routing-role"
  #aws_assume_role = "platform-vpc-role"
  aws_assume_role = "Terraform"
  module_source = "demo-module-aws-vpc"
  module_version = "0.0.1"
}

inputs = {
  vpc_secondary_cidr = "10.51.4.0/24"
  instance = "sbxdev-aws-${basename(get_terragrunt_dir())}"
  cluster_domain = local.role_vars.locals.cluster_domain
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region  = "${basename(get_terragrunt_dir())}"

  assume_role {
    role_arn = "arn:aws:iam::${local.role_vars.locals.aws_account_id}:role/${local.aws_assume_role}"
  }

  default_tags {
    tags = {
      Environment      = "${local.role_vars.locals.role}-aws-${basename(get_terragrunt_dir())}"
      ReleaseVersion   = "${local.module_source}:${local.module_version}"
      ProvisionedBy    = "Terraform"
    }
  }
}
EOF
}

generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  cloud {
    organization = "ianwhewlett"

    workspaces {
      name = "${local.role_vars.locals.project_name}-${basename(dirname(get_terragrunt_dir()))}-${local.role_vars.locals.role}-${basename(get_terragrunt_dir())}"
    }
  }
}
EOF
}
