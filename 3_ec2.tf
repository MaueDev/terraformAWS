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
  availability_zone = var.RegionA
  subnet_id = aws_subnet.sa-east-1a_subnet_treinamento.id
  vpc_security_group_ids = [aws_security_group.public_security_testth.id]
  key_name = "testethnew"
  /*
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
          EOF*/
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y ",
      "sudo apt-get install -y git",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "sudo curl -sSL https://get.docker.com | sh",
      "sudo /etc/init.d/docker start",
      "sudo groupadd docker",
      "Sudo usermod -aG docker $USER",
      "sudo docker swarm init",
      "sudo docker network create --driver=overlay traefik-public",
      "sudo git clone https://github.com/MaueDev/StackDeployDocker.git",
      "cd StackDeployDocker/Traefik/",
      "sudo docker stack deploy traefik -c traefik_deploy.yaml",
      "sudo docker stack deploy testeth -c nginx_deploy.yaml"
    ]
    connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${self.public_ip}"
    private_key = "${file(".aws/testethnew.pem")}"
  }
  }
  tags = {
    Name = "Estancia-Teste-Tharlesson"
  }
}