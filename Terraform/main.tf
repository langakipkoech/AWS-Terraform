# Terraform configuration to create a simple AWS VPC with two public subnets, an internet gateway, and an EC2 instance with nginx installed

terraform {
  required_version = ">=1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

# Define the AWS provider
provider "aws" {
  region = "eu-central-1"
}

# Variables

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]  # Update as needed
}

variable "amis" {
  description = "Mapping of AMIs by region"
  type        = map(string)
  default     = {
    "eu-central-1" = "ami-08ec94f928cf25a9d"  # Replace with actual AMI ID
  }
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
}

# VPC definition
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo VPC trial"
  }
}

# Subnet definitions
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "subnet1"
    Type = "public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "subnet2"
    Type = "public"
  }
}

# Internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main gateway"
  }
}

# Route table and associations
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Main route table"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table1.id
}

# Security group
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Control traffic to the webserver"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow webserver to be reachable"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow traffic"
  }
}

# EC2 instance with nginx installation
resource "aws_instance" "web" {
  ami                    = var.amis[var.region]
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]

  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
apt-get -y update
apt-get -y install nginx

cd /var/www/html
rm *.html
git clone https://github.com/cloudacademy/webgl-globe/ .
cp -a src/* .
rm -rf .git *.md src conf.d docs Dockerfile index.nginx-debian.html

systemctl enable nginx
systemctl restart nginx

echo "Deployment complete - version 1.00"
EOF

  tags = {
    Name = "CloudAcademy"
  }
}
