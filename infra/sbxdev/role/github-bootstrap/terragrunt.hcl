include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  role_vars      = read_terragrunt_config(find_in_parent_folders("role.hcl"))
  module_source  = "demo-module-github-bootstrap"
  module_version = "0.0.1"
}

inputs = {
  repository_name = local.role_vars.locals.repository_name
  services        = jsondecode(read_tfvars_file("${find_in_parent_folders("services.json")}"))
  applications    = jsondecode(read_tfvars_file("${find_in_parent_folders("applications.json")}"))
}

terraform {
  source = "git@github.com:${include.root.locals.github_org}/${local.module_source}.git?ref=${local.module_version}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "github" {
  owner = "${include.root.locals.github_org}"
}
EOF
}
