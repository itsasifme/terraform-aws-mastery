# ---------- VPC: your own private network ----------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # gives instances a public DNS name

  tags = { Name = "${local.name_prefix}-vpc" }
}

# ---------- Internet gateway: the door between the VPC and the internet ----------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # reference = implicit dependency (VPC is created first)

  tags = { Name = "${local.name_prefix}-igw" }
}

# ---------- Public subnets: one per entry in var.public_subnets ----------
resource "aws_subnet" "public" {
  for_each = var.public_subnets # each.key = "a", each.value = "10.0.1.0/24"

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${var.aws_region}${each.key}" # "ap-south-1a"
  map_public_ip_on_launch = true                           # servers here get a public IP

  tags = { Name = "${local.name_prefix}-public-${each.key}" }
}

# ---------- Route table: "to reach the internet (0.0.0.0/0), go through the IGW" ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${local.name_prefix}-public-rt" }
}

# Attach the route table to every public subnet.
# Without this, the subnet has no road to the internet.
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public # loop over the subnets created above

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------- Security group: the firewall around the server ----------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP from anywhere and SSH from my IP"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${local.name_prefix}-web-sg" }
}

# Each rule is its own resource (the current AWS provider recommendation).
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH only from my IP, never 0.0.0.0/0"
  cidr_ipv4         = var.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Server can reach the internet (to install nginx)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
}
