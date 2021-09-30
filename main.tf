provider "aws" {
  region="ap-southeast-1"
  access_key = ""
  secret_key = ""
}

#VPC
resource "aws_vpc" "vpc" {
    cidr_block = "10.10.0.0/16"  
    tags = {
      Name = "vpc"
    }
}

#Internet Gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "gw"
    }
  
}

#Subnets
resource "aws_subnet" "subnet-a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.10.0.0/20" 
  availability_zone = "ap-southeast-1a"
}

resource "aws_subnet" "subnet-b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.10.16.0/20" 
  availability_zone = "ap-southeast-1b"
}

resource "aws_subnet" "subnet-c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.10.32.0/20" 
  availability_zone = "ap-southeast-1c"
}

#Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }

  tags = {
    Name = "rt"
  }
}

#Route Table Association
resource "aws_route_table_association" "az-a" {
  subnet_id = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "az-b" {
  subnet_id = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "az-c" {
  subnet_id = aws_subnet.subnet-c.id
  route_table_id = aws_route_table.rt.id
}