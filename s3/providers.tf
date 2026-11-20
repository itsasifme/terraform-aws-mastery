terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random" # used to make a unique bucket name
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Added to every AWS resource in this folder.
  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}
