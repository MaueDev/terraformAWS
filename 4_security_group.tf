resource "aws_security_group" "public_security_testth" {
  vpc_id = aws_vpc.vpc_treinamento.id
  
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
/*
    ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 8080 
    to_port    = 8080
  }
*/
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
}