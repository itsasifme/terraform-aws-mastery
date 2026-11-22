# Say which provider we need, but don't set it up here.
# The folder that uses this module sets the region and login.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0" # the folder that uses this module picks the version
    }
  }
}
