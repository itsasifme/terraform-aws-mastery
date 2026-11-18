# The "terraform" block: settings for Terraform itself.
terraform {
  required_version = ">= 1.5.0"

  # Which provider plugins to download during "terraform init".
  required_providers {
    aws = {
      source  = "hashicorp/aws" # namespace/provider on the Registry
      version = "~> 6.0"        # any 6.x, never 7.0
    }
    random = {
      source  = "hashicorp/random" # used to make a unique bucket name
      version = "~> 3.6"
    }
  }
}

# The "provider" block: how to talk to AWS.
provider "aws" {
  region = var.aws_region

  # These tags are added to every AWS resource this config creates.
  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}
