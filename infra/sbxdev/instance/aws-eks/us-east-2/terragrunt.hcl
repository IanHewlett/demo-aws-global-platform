include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  module_version = include.root.locals.module_version
}
