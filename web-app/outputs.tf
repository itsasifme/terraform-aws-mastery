output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Subnet IDs, keyed by AZ letter"
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "Open this in your browser"
  value       = "http://${aws_instance.web.public_ip}"
}
