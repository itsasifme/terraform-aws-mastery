terraform {
  required_version = ">= 1.11.0" # use_lockfile needs 1.11+

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "terraform-aws-mastery"
      Environment = "stag"
      Component   = "app"
      ManagedBy   = "terraform"
    }
  }
}
