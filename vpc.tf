# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "my-vpc" }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "public-subnet-1" }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = { Name = "public-subnet-2" }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "private-subnet-2" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "my-igw" }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "public-route-table" }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for ELB
resource "aws_security_group" "elb_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "elb-security-group" }
}

# ELB
resource "aws_elb" "my_elb" {
  name               = "my-elb"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_groups    = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port          = 80
    lb_protocol      = "HTTP"
  }

  listener {
    instance_port     = 443
    instance_protocol = "HTTPS"
    lb_port          = 443
    lb_protocol      = "HTTPS"
    ssl_certificate_id = "arn:aws:acm:us-east-1:123456789012:certificate/example-cert"
  }

  tags = { Name = "my-load-balancer" }
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "my_zone" {
  name = "example.com"
}

# Route 53 CNAME record
resource "aws_route53_record" "cname_record" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = "www.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elb.my_elb.dns_name]
}
