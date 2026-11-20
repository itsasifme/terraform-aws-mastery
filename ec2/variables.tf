variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to tag and name resources"
  type        = string
  default     = "terraform-aws-learning"
}

variable "environment" {
  description = "Which environment this is"
  type        = string
  default     = "dev"

  # Stops typos like "prd" before anything reaches AWS.
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"

  # Only allow Free Tier sizes so we don't get a surprise bill.
  validation {
    condition     = contains(["t3.micro", "t2.micro"], var.instance_type)
    error_message = "Use a Free Tier size: t3.micro or t2.micro."
  }
}

variable "api_key" {
  description = "Fake secret, only to show how 'sensitive' hides values"
  type        = string
  default     = "not-a-real-secret"
  sensitive   = true # Terraform prints (sensitive value) instead of the real value
}
