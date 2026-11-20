resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public["a"].id # pick subnet "a" from the map
  vpc_security_group_ids = [aws_security_group.web.id]

  # Script that runs once, on first boot. Installs nginx and writes a home page.
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>Hello from Terraform!</h1><p>Server: ${local.name_prefix}-web</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF

  # If the script changes, build a new server (user_data only runs on first boot).
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  # Nothing above references the route table association, so Terraform can't know
  # the server needs internet during boot. depends_on tells it: wait for the route first.
  depends_on = [aws_route_table_association.public]

  tags = { Name = "${local.name_prefix}-web" }
}
