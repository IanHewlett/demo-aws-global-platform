include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  module_version = include.root.locals.module_version
}

inputs = {
  vpc_azs = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]
  vpc_cidr = "10.241.0.0/16"
  vpc_private_subnets = [
    "10.241.0.0/18",
    "10.241.64.0/18",
    "10.241.128.0/18"
  ]
  vpc_public_subnets = [
    "10.241.240.0/26",
    "10.241.240.64/26",
    "10.241.240.128/26"
  ]
  vpc_database_subnets = [
    "10.241.192.0/20",
    "10.241.208.0/20",
    "10.241.224.0/20"
  ]
  vpc_intra_subnets = [
    "10.51.4.0/28",
    "10.51.4.16/28",
    "10.51.4.32/28"
  ]
}

terraform {
  source = "git@github.com:${include.root.locals.role_vars.locals.github_org}/${include.root.locals.module_source}.git?ref=${local.module_version}"
}
