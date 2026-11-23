output "state_bucket" {
  description = "Name of the state bucket"
  value       = aws_s3_bucket.state.bucket
}

output "backend_hcl" {
  description = "Copy this into ../backend.hcl"
  value       = <<-EOT
    bucket = "${aws_s3_bucket.state.bucket}"
    region = "${var.aws_region}"
  EOT
}
