provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA2GV7V4IAC4WJPIGC"
  secret_key = "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"
}

# Creating VPC For prod
resource "aws_vpc" "pieeye-prod-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name     = var.prod_vpc
    pieeye = "true"
  }
}
# Creating Private-subnet1 For prod
resource "aws_subnet" "pieeye-prod-private-subnet1" {
  vpc_id            = aws_vpc.pieeye-prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    name     = var.prod_private_subnet1
    pieeye = "true"
  }
}
# Creating Private-subnet2 For prod
resource "aws_subnet" "pieeye-prod-private-subnet2" {
  vpc_id            = aws_vpc.pieeye-prod-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    name     = var.prod_private_subnet2
    pieeye = "true"
  }
}
# Creating Public-subnet For prod
resource "aws_subnet" "pieeye-prod-public-subnet1" {
  vpc_id            = aws_vpc.pieeye-prod-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    name     = var.prod_public_subnet1
    pieeye = "true"
  }
}
# Creating Public-subnet2 For prod
resource "aws_subnet" "pieeye-prod-public-subnet2" {
  vpc_id            = aws_vpc.pieeye-prod-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    name     = var.prod_public_subnet2
    pieeye = "true"
  }
}
# Creating internet-gateway For prod
resource "aws_internet_gateway" "pieeye-prod-igw" {

  depends_on = [
    aws_vpc.pieeye-prod-vpc,
  ]
  vpc_id = aws_vpc.pieeye-prod-vpc.id
  tags = {
    Name     = var.prod_igw
    pieeye = "true"
  }
}
# Creating route-table For aws_internet_gateway
resource "aws_route_table" "pieeye-prod-rt" {

  depends_on = [
    aws_internet_gateway.pieeye-prod-igw,
  ]
  vpc_id = aws_vpc.pieeye-prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pieeye-prod-igw.id
  }
  tags = {
    Name     = "prod_rt"
    pieeye = "true"
  }
}
# Associating route-table to public subnet	
resource "aws_route_table_association" "pieeye-prod-rt-association" {
  subnet_id      = aws_subnet.pieeye-prod-public-subnet1.id
  route_table_id = aws_route_table.pieeye-prod-rt.id
}
# Creating eip For nat-gateway
resource "aws_eip" "pieeye-prod-eip-nat" {
  vpc = true
}
# Creating nat-gateway
resource "aws_nat_gateway" "pieeye-prod-nat" {
  allocation_id = aws_eip.pieeye-prod-eip-nat.id
  subnet_id     = aws_subnet.pieeye-prod-public-subnet1.id
  tags = {
    Name     = var.prod_nat
    pieeye = "true"
  }
}
# Crearing nat-route
resource "aws_route_table" "pieeye-prod-nat-route" {
  vpc_id = aws_vpc.pieeye-prod-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pieeye-prod-nat.id
  }
  tags = {
    Name     = var.prod_nat_route
    pieeye = "true"
  }
}
# Associating nat-route to private-subnet1
resource "aws_route_table_association" "pieeye-prod-associate" {
  subnet_id      = aws_subnet.pieeye-prod-private-subnet1.id
  route_table_id = aws_route_table.pieeye-prod-nat-route.id
}
# Associating nat-route to private-subnet2
resource "aws_route_table_association" "pieeye-prod-associate2" {
  subnet_id      = aws_subnet.pieeye-prod-private-subnet2.id
  route_table_id = aws_route_table.pieeye-prod-nat-route.id
}
