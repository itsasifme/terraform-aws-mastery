output "website_url" {
  description = "Open this in your browser"
  value       = "http://${module.web.public_ip}"
}
