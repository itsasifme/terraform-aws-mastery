terraform {
  backend "s3" {
    key          = "dev/app/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
