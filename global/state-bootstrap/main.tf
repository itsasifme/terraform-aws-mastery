# Who am I? Gives the AWS account ID, so the bucket name is unique without random_id.
data "aws_caller_identity" "current" {}

# ---------- The bucket that will hold every folder's terraform.tfstate ----------
resource "aws_s3_bucket" "state" {
  bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Lab only, so the bucket can be emptied and removed at the very end.
  # In a real company this is false.
  force_destroy = true

  tags = { Name = "terraform-state" }

  # Losing this bucket means losing every state file. Terraform refuses any
  # plan that would delete it. To really remove it, delete this block first.
  lifecycle {
    prevent_destroy = true
  }
}

# Keep every old version of each state file. If state gets broken, roll back.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt files at rest. State can hold secrets in plain text.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Never let this bucket become public.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
