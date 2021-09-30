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

resource "aws_security_group" "sg_public" {
  name        = "public"
  description = "public inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress  {
      description      = "TLS from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "pulibc"
  }
}

#Application Load Balancer
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_public.id]
  subnets            = [aws_subnet.subnet-a.id,aws_subnet.subnet-b.id,aws_subnet.subnet-c.id]

  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}