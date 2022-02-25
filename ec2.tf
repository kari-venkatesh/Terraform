provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA2GV7V4IAC4WJPIGC"
  secret_key = "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"
}
# Creating EC2 amazon-linux2
  resource "aws_instance" "ec2-web" {
  ami = "ami-0c6615d1e95c98aca"
  instance_type = "t2.micro"
  key_name = "cpsoft"
  availability_zone = "ap-south-1"
  subnet_id = aws_subnet.public-subnet.id 
  vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ec2-profile.id}"
  
tags = {
    Name = "Ec2-web"
  }
}

# Creating VPC
resource "aws_vpc" "vpc" {
   cidr_block = "10.0.0.0/16"
   instance_tenancy = "default"
   enable_dns_hostnames = true
   
tags = {
     name = "vpc"
   }
}

# Creating subnet
   resource "aws_subnet" "public-subnet" {
   vpc_id = "${aws_vpc.vpc.id}"
   cidr_block = "10.0.0.0/24"
   availability_zone = "ap-south-1a"
      
tags = {
     name = "public-subnet"
   }
}

# Security group for EC2
resource "aws_security_group" "ec2-sg" {
  name = "ec2-sg"
  description ="Security group for EC2"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
       Name = "EC2-web"
	  }
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = ["ec2-role"]
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}