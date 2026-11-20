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
