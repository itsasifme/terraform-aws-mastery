terraform {
  backend "s3" {
    key          = "stag/app/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
