# Network for prod, built with the community VPC module from the Terraform Registry.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0" # always pin Registry modules

  name = "terraform-aws-mastery-prod"
  cidr = "10.1.0.0/16"

  azs            = ["ap-south-1a", "ap-south-1b"]
  public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]

  map_public_ip_on_launch = true  # servers in public subnets get a public IP
  enable_nat_gateway      = false # NAT costs money, and we have no private subnets
}
