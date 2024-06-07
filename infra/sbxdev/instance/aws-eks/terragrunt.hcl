locals {
  role_vars       = read_terragrunt_config(find_in_parent_folders("role.hcl"))
  aws_assume_role = "platform-eks-role"
  module_source   = "demo-module-aws-eks"
  module_version  = "0.0.1"
}

inputs = {
  role                                = local.role_vars.locals.role
  aws_region                          = "${basename(get_terragrunt_dir())}"
  instance                            = "sbxdev-aws-${basename(get_terragrunt_dir())}"
  aws_account_id                      = local.role_vars.locals.aws_account_id
  aws_assume_role                     = local.aws_assume_role
  cluster_eks_version                 = "1.27"
  vpc_cni_version                     = "v1.18.0-eksbuild.1"
  kube_proxy_version                  = "v1.27.3-eksbuild.1"
  coredns_version                     = "v1.10.1-eksbuild.2"
  aws_ebs_csi_driver_version          = "v1.20.0-eksbuild.1"
  management_node_group_name          = local.role_vars.locals.management_node_group_name
  management_node_group_role          = local.role_vars.locals.management_node_group_role
  management_node_group_ami_type      = "AL2_x86_64"
  management_node_group_platform      = "linux"
  management_node_group_disk_size     = "50"
  management_node_group_capacity_type = "SPOT"
  management_node_group_desired_size  = "3"
  management_node_group_max_size      = "5"
  management_node_group_min_size      = "3"
  management_node_group_instance_types = [
    "t2.2xlarge",
    "t3.2xlarge",
    "t3a.2xlarge",
    "m5.2xlarge"
  ]
  aws_auth_roles = [
    {
      "rolearn" : "arn:aws:iam::${local.role_vars.locals.aws_account_id}:role/platform-eks-role",
      "username" : "platform-eks-role",
      "groups" : [
        "system:masters"
      ]
    }
  ]
}

terraform {
  source = "git@github.com:${local.role_vars.locals.github_org}/${local.module_source}.git?ref=${local.module_version}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "vault" {
  address = "${local.role_vars.locals.vault_addr}"
  namespace = "admin"
}
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
  contents  = <<EOF
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
