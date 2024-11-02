# ./vpc.tf

# VPC
resource "aws_vpc" "vpc03" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# IGW
resource "aws_internet_gateway" "vpc03" {
  vpc_id = aws_vpc.vpc03.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# パブリックサブネット
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.vpc03.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

# ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc03.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc03.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# サブネットとルートテーブル関連付け
resource "aws_route_table_association" "public_rt_asso" {
  count        = length(var.public_subnets)
  subnet_id    = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

# セキュリティグループ
resource "aws_security_group" "asg_sg" {
  vpc_id = aws_vpc.vpc03.id

  # Ingress：HTTP通信を全体から許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress：SSHアクセスを全体から許可
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (アウトバウンド) - 全ての通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}