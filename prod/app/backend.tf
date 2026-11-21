terraform {
  backend "s3" {
    key          = "prod/app/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
