provider "aws" {
    profile = "default"
    region  = "us-east-1"
}
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "terraform-toktosunov-s3"
    acl    = "private"
}
resource "aws_vpc" "new_vpc" {
    cidr_block = "10.1.0.0/16"
}
resource "aws_subnet" "new_vpc_subnet-1" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "new_vpc_subnet-2" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1b"
}
resource "aws_security_group" "web" {
    name        = "terraform_sg"
    description = "simple descrition"
    vpc_id      = aws_vpc.new_vpc.id
    ingress     = [ {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "value"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [ ]
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "value"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [ ]
      self             = false
      to_port          = 80
    }]
    egress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "value"
      from_port = 0
      ipv6_cidr_blocks = [  ]
      prefix_list_ids  = [  ]
      protocol         = "-1"
      security_groups  = [  ]
      self             = false
      to_port          = 0
    } ]
    
}
resource "aws_autoscaling_group" "terraform" {
  name     = "nginx-autoscaling-group"
  max_size = 3
  min_size = 2
  vpc_zone_identifier = [aws_subnet.new_vpc_subnet-1.id,aws_subnet.new_vpc_subnet-2.id]
  launch_template {
    id = aws_launch_template.terraform.id
  }
  target_group_arns = [ aws_lb_target_group.terraform_elb.arn]

}
resource "aws_launch_template" "terraform" {

  name_prefix            = "terraform-nginx"
  instance_type          = "t2.micro"
  image_id               = "ami-0ad235070aed081b7"
  key_name               = "default"
  vpc_security_group_ids = [ aws_security_group.web.id ]
}

resource "aws_lb" "terraform_elb" {
  internal           = true
  subnets            = [ aws_subnet.new_vpc_subnet-1.id, aws_subnet.new_vpc_subnet-2.id ]
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}
resource "aws_lb_target_group" "terraform_elb" {
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.new_vpc.id
}
resource "aws_lb_listener" "terraform_elb" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform_elb.arn
  }
  load_balancer_arn = aws_lb.terraform_elb.arn
  protocol          = "HTTP"
  port              = 80
}