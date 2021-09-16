resource "aws_vpc" "vpc_treinamento" {
  cidr_block = var.VpcCIDRBlock
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
tags = {
  name = "VPC Treinamento"
}
}

resource "aws_subnet" "sa-east-1a_subnet_treinamento" {
  vpc_id = aws_vpc.vpc_treinamento.id
  cidr_block =  "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.RegionA
tags = {
  Name = "Subnet sa-east-1a Treinamento"
}
}

resource "aws_subnet" "sa-east-1b_subnet_treinamento" {
  vpc_id = aws_vpc.vpc_treinamento.id
  cidr_block =  "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.RegionB
tags = {
  Name = "Subnet sa-east-1b Treinamento"
}
}

resource "aws_internet_gateway" "igw_treinamento" {
  vpc_id = aws_vpc.vpc_treinamento.id
  tags = {
    Name = "Internet Gateway Treinamento"
  }
  
}

resource "aws_route_table" "route_table_treinamento" {
  vpc_id = aws_vpc.vpc_treinamento.id
  tags = {
    Name = "Route Table Treinamento"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.route_table_treinamento.id
  destination_cidr_block = var.DestCIDRBlock
  gateway_id             = aws_internet_gateway.igw_treinamento.id
}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.sa-east-1a_subnet_treinamento.id
  route_table_id = aws_route_table.route_table_treinamento.id
}