# Store this folder's state in S3 instead of a local file.
# A backend block can't use variables, so the bucket and region come from
# ../backend.hcl at init time:  terraform init -backend-config=../backend.hcl
terraform {
  backend "s3" {
    key          = "web-app/terraform.tfstate" # path inside the bucket, one per folder
    encrypt      = true                        # encrypt the state file in S3
    use_lockfile = true                        # S3 lock file stops two applies at once
  }
}
