terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = "~> 1.0"

  backend "remote" {
    organization = "lavery-digital-personal"

    workspaces {
      name = "personal-github-actions"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami                    = "ami-0731becbf832f281e"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Everyone!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "terraform-github-actions-demo"
  }
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "${random_pet.sg.id}-sg"
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}