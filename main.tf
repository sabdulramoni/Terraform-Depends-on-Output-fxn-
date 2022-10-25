terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "my_web_server" {
    ami =  "ami-089a545a9ed9893b6"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.general.id]
    tags = {Name =  "Server-web"}

    depends_on = [
      aws_instance.my_database
    ]
  
}

resource "aws_instance" "my_app_server" {
    ami =  "ami-089a545a9ed9893b6"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.general.id]
    tags = {Name =  "Server-app"}

    depends_on = [
      aws_instance.my_database,
      aws_instance.my_web_server
    ]
  
}

resource "aws_instance" "my_database" {
    ami =  "ami-089a545a9ed9893b6"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.general.id]
    tags = {Name =  "Server-db"}
  
}

resource "aws_security_group" "general" {
    name = "My SG Terraform"

    dynamic "ingress" {
    for_each = ["80", "443", "3389"]
    content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

}
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "security_group_id" {
    value = aws_security_group.general.id
  
}

output "my_app_server" {
    value = aws_instance.my_app_server.private_ip
  
}

output "my_web_server" {
    value = aws_instance.my_web_server.private_ip
  
}

output "my_database_server" {
    value = aws_instance.my_database.private_ip
  
}