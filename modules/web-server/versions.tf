# A module says which providers it needs, but never configures them.
# The region and credentials come from whoever calls the module.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0" # loose on purpose: callers pin the exact version
    }
  }
}
