output "aws_region" {
  description = "Region in use"
  value       = var.aws_region
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ami_name" {
  description = "Which AMI the data source found"
  value       = data.aws_ami.amazon_linux.name
}

output "availability_zone" {
  description = "AZ the instance runs in"
  value       = aws_instance.web.availability_zone
}

output "api_key" {
  description = "Shows how sensitive outputs are hidden"
  value       = var.api_key
  sensitive   = true # required, because var.api_key is sensitive
}
