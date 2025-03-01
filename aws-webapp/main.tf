terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-playbooks-state-1"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    key            = "bootstrap-ts-backend"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "web_public" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnets[0].id
  security_groups = [aws_security_group.web_sg.id, aws_security_group.all_ssh_sg.id]
  user_data       = file("userdata.sh")

  tags = {
    Name = "public_instance"
  }
}

resource "aws_instance" "web_private" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnets[0].id
  security_groups = [aws_security_group.web_sg.id, aws_security_group.private_ssh_sg.id]
  user_data       = file("userdata.sh")

  tags = {
    Name = "private_instance"
  }
}
