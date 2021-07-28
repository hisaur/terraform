provider "aws" {
    profile = "default"
    region = "us-east-1"
}
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "terraform-toktosunov-s3"
    acl = "private"
}
resource "aws_vpc" "new_vpc" {
    cidr_block = "10.1.0.0/16"
}
resource "aws_subnet" "new_vpc_subnet-1" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "new_vpc_subnet-2" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1b"
}
resource "aws_security_group" "web" {
    name = "terraform_sg"
    description = "simple descrition"
    vpc_id = aws_vpc.new_vpc.id
    ingress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "value"
      from_port = 443
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "tcp"
      security_groups = [ ]
      self = false
      to_port = 443
    },
    {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "value"
      from_port = 80
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "tcp"
      security_groups = [ ]
      self = false
      to_port = 80
    }]
    egress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "value"
      from_port = 0
      ipv6_cidr_blocks = [  ]
      prefix_list_ids = [  ]
      protocol = "-1"
      security_groups = [  ]
      self = false
      to_port = 0
    } ]
    
}
resource "aws_ebs_volume" "terraform-ssd" {
  availability_zone = "us-east-1a"
  size = 40
  type = "gp2"
  
  tags = {
    Creator = "Terraform"
  }
}
resource "aws_autoscaling_group" "terraform-nginx" {
  name = "nginx-autoscaling-group"
  max_size = 3
  min_size = 2
  vpc_zone_identifier = [aws_subnet.new_vpc_subnet-1,aws_subnet.new_vpc_subnet-2]
  
}

resource "aws_launch_template" "terraform-nginx" {
  name = "terraform-nginx-template"
  instance_type = "t2.micro"
  image_id = "ami-0ad235070aed081b7"
  block_device_mappings {
    device_name = "/dev/sdc1"
    ebs {
      volume_size = 20
    }
  }
  
}
resource "aws_instance" "aws_linux" {
  ami           = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.web.id ]
  
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = 40
    volume_type = "gp2" 
  }
  subnet_id = aws_subnet.new_vpc_subnet-1.id
  key_name = "default"
  tags = {
    Creator = "Terraform"
  }
}
resource "aws_lb" "terraform_elb" {
  internal = true
  subnets = [ aws_subnet.new_vpc_subnet-1.id, aws_subnet.new_vpc_subnet-2.id ]
  ip_address_type = "ipv4"
  load_balancer_type = "network"
}
resource "aws_lb_target_group_attachment" "terraform_elb" {
  target_group_arn = aws_lb_target_group.terraform_elb.arn
  target_id = aws_instance.aws_linux.private_ip

}
resource "aws_lb_target_group" "terraform_elb" {
  target_type = "ip"
  port = 80
  protocol = "TCP"
  vpc_id = aws_vpc.new_vpc.id

}
resource "aws_lb_listener" "terraform_elb" {
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.terraform_elb.arn
  }
  load_balancer_arn = aws_lb.terraform_elb.arn
  protocol = "TCP"
  port = 80
}