terraform {
  backend "s3" {
    key          = "dev/network/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
