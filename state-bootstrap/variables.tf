variable "aws_region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Used in the bucket name and tags"
  type        = string
  default     = "terraform-aws-learning"
}
