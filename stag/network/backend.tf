terraform {
  backend "s3" {
    key          = "stag/network/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
