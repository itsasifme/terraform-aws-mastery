# Get the AWS account ID. We add it to the bucket name so the name is unique.
data "aws_caller_identity" "current" {}

# ---------- Bucket for all state files ----------
resource "aws_s3_bucket" "state" {
  bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Lets us delete the bucket even if it has files. Only for this lab.
  # In a real company, keep this false.
  force_destroy = true

  tags = { Name = "terraform-state" }

  # Never delete this bucket. It holds every state file.
  # To remove it on purpose, delete this block first.
  lifecycle {
    prevent_destroy = true
  }
}

# Keep old versions of each state file, so we can go back if something breaks.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt the files. State can have passwords in plain text.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Never allow public access.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
