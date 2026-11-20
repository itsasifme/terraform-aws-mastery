# One small EC2 server in your account's default VPC.
resource "aws_instance" "web" {
  ami               = data.aws_ami.amazon_linux.id                   # from data.tf
  instance_type     = var.instance_type                              # from variables.tf / tfvars
  availability_zone = data.aws_availability_zones.available.names[0] # first AZ in the list

  # Require IMDSv2 (a security best practice; checkov and tflint will warn without it).
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name        = "${local.name_prefix}-web" # from locals.tf
    Environment = var.environment
  }
}
