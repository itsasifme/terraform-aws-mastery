variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "ap-south-1"
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

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t2.micro"], var.instance_type)
    error_message = "Use a Free Tier size: t3.micro or t2.micro."
  }
}

variable "vpc_cidr" {
  description = "IP range for the whole VPC"
  type        = string
  default     = "10.0.0.0/16" # 65,536 addresses
}

# One public subnet per entry. Key = AZ letter, value = IP range.
# A map works with for_each, so removing "b" later only removes subnet "b".
variable "public_subnets" {
  description = "Public subnets: AZ letter => CIDR"
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }
}

variable "my_ip" {
  description = "Your public IP in CIDR form (x.x.x.x/32). Only this IP can use SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "my_ip must be a CIDR like 103.0.0.1/32."
  }
}
