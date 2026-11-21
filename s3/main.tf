# 4 random bytes = 8 hex characters, e.g. "a1b2c3d4".
# S3 bucket names must be unique across ALL AWS accounts, so we add this suffix.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "learning" {
  bucket = "${var.project_name}-${random_id.bucket_suffix.hex}"

  # Lets "terraform destroy" delete the bucket even if it has files in it.
  # Fine for labs, but don't use it on real data.
  force_destroy = true

  tags = {
    Name        = "my-first-terraform-bucket"
    Environment = "learning"
  }
}


# Created by hand outside Terraform, then imported
resource "aws_s3_bucket" "imported" {
  bucket = "terraform-aws-learning-imported-d6e1a945"

  tags = {
    Name = "imported-bucket"
  }
}