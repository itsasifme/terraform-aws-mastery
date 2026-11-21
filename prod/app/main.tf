# Read the outputs of prod/network from its state file in S3.
# Unlike a backend block, a data source CAN use variables.
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "prod/network/terraform.tfstate"
    region = "ap-south-1"
  }
}

# Same module as the other environments. Only the inputs differ.
module "web" {
  source = "../../modules/web-server" # local module: a path, no version

  name          = "terraform-aws-mastery-prod"
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  instance_type = "t3.micro"
  ssh_cidr      = var.ssh_cidr
}
