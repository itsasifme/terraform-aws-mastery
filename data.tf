# data = READ something that already exists in AWS. Terraform never creates or deletes it.

# Find the newest Amazon Linux 2023 image (AMI) in this region.
# AMI IDs are different in every region, so we look it up instead of hard-coding it.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# List the availability zones in this region, e.g. ap-south-1a, ap-south-1b, ...
data "aws_availability_zones" "available" {
  state = "available"
}
