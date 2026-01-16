terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
}


# Provisioning security group that allows SSH and tomcat
resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat_sg"
  description = "Allow SSH and tomcat traffic"
  #vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "Tomcat"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


}

# EC2 Instance
resource "aws_instance" "tomcat_ec2" {
  ami           = "ami-07ff62358b87c7116"
  instance_type = "t2.micro"
  key_name      = "WinAccessKey"
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
}

# Auto generate ansible inventory file
resource "local_file" "ansible_inventory" {
  content = <<EOT
  [tomcat]
  ${aws_instance.tomcat_ec2.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/WinAccessKey.pem
  EOT

  filename = "${path.module}/inventory.ini"
}

# Outputing the public IP for ansible inventory
output "tomcat_public-ip" {
  description = "Tomcat public ip"
  value = aws_instance.tomcat_ec2.public_ip
}