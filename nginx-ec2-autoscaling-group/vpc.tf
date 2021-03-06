provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
variable "env" {
  type    = string
  default = "prod"
}
variable "ami-id" {
  type = string
  #AMI is Amazon Linux 2
  default = "ami-0c2b8ca1dad447f8a"
}
variable "instance-type" {
  type    = string
  default = "t2.micro"
}
variable "autoscaling-group-min-size" {
  type    = number
  default = 2
}
variable "autoscaling-group-max-size" {
  type    = number
  default = 3
}
resource "aws_vpc" "new_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_default_route_table" "terraform" {
  default_route_table_id = aws_vpc.new_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform.id
  }
}

resource "aws_internet_gateway" "terraform" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_subnet" "new_vpc_subnet-1" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_subnet" "new_vpc_subnet-2" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}