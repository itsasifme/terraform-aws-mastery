# Get the latest Amazon Linux 2023 image.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------- Security group ----------
resource "aws_security_group" "this" {
  # AWS adds a random ending to this name. So the old and the new
  # group can live together for a short time.
  name_prefix = "${var.name}-web-"
  description = "Web server: HTTP from anywhere, optional SSH"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-web-sg" }

  # Works only when the group must be replaced, for example when you
  # change the name or description (plan shows "forces replacement").
  # Then it makes the new group first and deletes the old one last,
  # because AWS can't delete a group while the server still uses it.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.this.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Make this rule only when ssh_cidr is set.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count = var.ssh_cidr == null ? 0 : 1

  security_group_id = aws_security_group.this.id
  description       = "SSH from one IP only"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Server can reach the internet"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------- Server ----------
resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>Hello from a Terraform module!</h1><p>Server: ${var.name}-web</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF

  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  tags = { Name = "${var.name}-web" }

  # Works on every plan. Amazon releases a new AMI almost every week,
  # and without this Terraform would replace the server each time.
  # To update the server yourself: terraform apply -replace=<address>
  lifecycle {
    ignore_changes = [ami]
  }
}
