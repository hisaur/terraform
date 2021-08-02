resource "aws_security_group" "web" {
    name        = "terraform_sg"
    description = "SG for EC2 with HTTP,HTTPS and SSH"
    vpc_id      = aws_vpc.new_vpc.id
    ingress     = [ {
      cidr_blocks      = []
      description      = "HTTPS Traffic from ELB"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.http.id  ]
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks      = []
      description      = "HTTP Traffic from ELB"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.http.id ]
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "SSH for management"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [ ]
      self             = false
      to_port          = 22
    }]
    egress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description      = "Allow to everywhere"
      from_port        = 0
      ipv6_cidr_blocks = [  ]
      prefix_list_ids  = [  ]
      protocol         = "-1"
      security_groups  = [  ]
      self             = false
      to_port          = 0
    } ]
    tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}

resource "aws_security_group" "http" {
  name        = "terraform_sg_http_only"
  vpc_id      = aws_vpc.new_vpc.id
  ingress     = [ {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "HTTP Traffic"
      from_port        = 80
      to_port          = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [ ]
      self             = true
    },
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "HTTPS Traffic"
      from_port        = 443
      to_port          = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [ ]
      self             = true
    },
  ]
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "Traffic to EC2"
      from_port        = 80
      to_port          = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
    }
  ]
  tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
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
  #AMI is Amazon Linux2
  image_id               = "ami-0c2b8ca1dad447f8a"
  key_name               = "default"
  user_data = base64encode(templatefile("${path.module}/startup.sh",{
    bucket_name = aws_s3_bucket.terraform.bucket,
    index_key   = aws_s3_bucket_object.terraform-index.key,
    error_key   = aws_s3_bucket_object.terraform-error.key
    }))
  iam_instance_profile {
    arn = aws_iam_instance_profile.terraform.arn
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [ aws_security_group.web.id ]
  }
  tags = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}

resource "aws_lb" "terraform_elb" {
  internal           = false
  subnets            = [ aws_subnet.new_vpc_subnet-1.id, aws_subnet.new_vpc_subnet-2.id ]
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.http.id ]
  tags               = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_lb_target_group" "terraform_elb" {
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.new_vpc.id
  tags        = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_lb_listener" "terraform_elb" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform_elb.arn
  }
  load_balancer_arn  = aws_lb.terraform_elb.arn
  protocol           = "HTTP"
  port               = 80
  tags               = {
    "Creator"     = "Terraform"
    "Environment" = var.env
  }
}
