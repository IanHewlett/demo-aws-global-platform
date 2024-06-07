locals {
  role_vars       = read_terragrunt_config(find_in_parent_folders("role.hcl"))
  aws_account_id  = "${local.role_vars.locals.aws_account_id}"
  aws_region      = "${basename(get_terragrunt_dir())}"
  instance        = "sbxdev-aws-${basename(get_terragrunt_dir())}"
  aws_assume_role = "platform-eks-role"
  module_source   = "demo-module-flux-bootstrap"
  module_version  = "0.0.1"
}

inputs = {
  role                               = local.role_vars.locals.role
  instance                           = local.instance
  aws_account_id                     = local.role_vars.locals.aws_account_id
  aws_region                         = local.aws_region
  aws_assume_role                    = local.aws_assume_role
  github_org                         = local.role_vars.locals.github_org
  repository_name                    = local.role_vars.locals.repository_name
  vault_addr                         = local.role_vars.locals.vault_addr
  cluster_domain                     = local.role_vars.locals.cluster_domain
  management_node_group_name         = local.role_vars.locals.management_node_group_name
  management_node_group_role         = local.role_vars.locals.management_node_group_role
  irsa_aws_load_balancer_controller  = "arn:aws:iam::${local.aws_account_id}:role/${local.instance}-aws-load-balancer-controller"
  irsa_cert_manager                  = "arn:aws:iam::${local.aws_account_id}:role/${local.instance}-cert-manager"
  irsa_karpenter_controller          = "arn:aws:iam::${local.aws_account_id}:role/${local.instance}-karpenter-controller"
  irsa_external_dns                  = "arn:aws:iam::${local.aws_account_id}:role/${local.instance}-external-dns"
  istio_ingressgateway_name          = "ingress-${local.role_vars.locals.role}-${local.aws_region}"
  istio_intragateway_name            = "intra-${local.role_vars.locals.role}-${local.aws_region}"
  karpenter_default_instance_profile = "${local.instance}-common-node-role"
  namespaces                         = jsondecode(read_tfvars_file("${find_in_parent_folders("namespaces.json")}")).namespaces
}

terraform {
  source = "git@github.com:${local.role_vars.locals.github_org}/${local.module_source}.git?ref=${local.module_version}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "github" {
  owner = "${local.role_vars.locals.github_org}"
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
