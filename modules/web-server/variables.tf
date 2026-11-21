variable "name" {
  description = "Prefix for every resource name, e.g. terraform-aws-mastery-dev"
  type        = string
}

variable "vpc_id" {
  description = "VPC to put the security group in"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet for the server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t2.micro"], var.instance_type)
    error_message = "Keep it small to save cost: t3.micro or t2.micro."
  }
}

variable "ssh_cidr" {
  description = "IP allowed to SSH (x.x.x.x/32). Leave null to turn SSH off."
  type        = string
  default     = null
}
