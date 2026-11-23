terraform {
  required_version = ">= 1.11.0" # same as every other root folder

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # No backend here. This folder makes the state bucket, so its own
  # state can't be saved in that bucket. It stays on this computer.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Component = "bootstrap"
      ManagedBy = "terraform"
    }
  }
}
