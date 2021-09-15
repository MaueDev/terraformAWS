provider "aws" {
  region  = "sa-east-1"
  shared_credentials_file = ".aws/credentials"
  profile = "awsterraform"
}
#Primeira Etapa Criar VPC
resource "aws_vpc" "vpc_testeth" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
tags = {
  name = "VPC Teste TH"
}
}

resource "aws_security_group" "public_security_testth" {
  vpc_id = aws_vpc.vpc_testeth.id
  
  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 80 
    to_port    = 80
  }

    ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 8080 
    to_port    = 8080
  }

  ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 22 
    to_port    = 22
  }

  egress {
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 0 
    to_port    = 0
  }

tags = {
    Name = "Public NACL"
}
}
#Segunda Etapa Criar Duas subnet
resource "aws_subnet" "public_subnet_testeth" {
  vpc_id = aws_vpc.vpc_testeth.id
  cidr_block =  "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "sa-east-1a"
tags = {
  Name = "Subnet Publica Teste TH"
}
}

resource "aws_subnet" "private_subnet_testeth" {
  vpc_id = aws_vpc.vpc_testeth.id
  cidr_block =  "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "sa-east-1b"
tags = {
  Name = "Subnet Privada Teste TH"
}
}
#Criando Gateway

resource "aws_internet_gateway" "igw_testeth" {
  vpc_id = aws_vpc.vpc_testeth.id
  tags = {
    Name = "Internet Gateway teste TH"
  }
  
}

resource "aws_route_table" "public_route" {

  vpc_id = aws_vpc.vpc_testeth.id
  tags = {
    Name = "route teste TH"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_testeth.id
}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.public_subnet_testeth.id
  route_table_id = aws_route_table.public_route.id
}


#Etapa 3 Criar Estancia

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "TesteThEstancia" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  availability_zone = "sa-east-1a"
  subnet_id = aws_subnet.public_subnet_testeth.id
  vpc_security_group_ids = [aws_security_group.public_security_testth.id]
  key_name = "testethnew"
  user_data = <<-EOF
          #!/bin/bash
          sudo apt-get update
          sudo apt-get git
          sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
          sudo curl -sSL https://get.docker.com | sh
          sudo /etc/init.d/docker start
          sudo chmod 666 /var/run/docker.sock
          docker swarm init
          docker network create --driver=overlay traefik-public
          sudo mkdir app
          cd app
          sudo git clone https://github.com/MaueDev/StackDeployDocker.git
          cd StackDeployDocker/Traefik/
          sudo docker stack deploy traefik -c traefik_deploy.yaml
          sudo docker stack deploy testeth -c nginx_deploy.yaml
          cd ~
          EOF

  tags = {
    Name = "Estancia-Teste-Tharlesson"
  }
}

#Caso precisar acessar Servidor