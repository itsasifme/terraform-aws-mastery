terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # No backend block on purpose: this folder creates the state bucket,
  # so its own state can't live in that bucket yet (chicken and egg).
  # It stays local. Companies keep this tiny and rarely touch it.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Component = "state-bootstrap"
      ManagedBy = "terraform"
    }
  }
}
