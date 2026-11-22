# Read the outputs of dev/network from its state file in S3.
# A data source can use variables. A backend block can't.
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "dev/network/terraform.tfstate"
    region = "ap-south-1"
  }
}

# Same module in every environment. Only the values change.
module "web" {
  source = "../../modules/web-server" # local module: just a path, no version

  name          = "terraform-aws-mastery-dev"
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  instance_type = "t3.micro"
  ssh_cidr      = var.ssh_cidr
}
