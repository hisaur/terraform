provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "bastion" {
    ami = "ami-0c2b8ca1dad447f8a"
    associate_public_ip_address = true
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.terraform.id
    vpc_security_group_ids =  [aws_security_group.ssh.id]
    key_name = "devOpsLab"
    user_data_base64 = "IyEvYmluL2Jhc2gKcHl0aG9uMyAtbSBwaXAgaW5zdGFsbCBib3RvMwpzdWRvIHRvdWNoIC9ob21lL2VjMi11c2VyLzE="
}

resource "aws_security_group" "ssh" {
  name   = "terraform_sg_ssh_only"
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "HTTP Traffic"
    from_port        = 22
    to_port          = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = true
    }
  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Traffic to EC2"
      from_port        = 0
      to_port          = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
    }
  ]
}
output "connection_string" {
  value = join(" ",["ssh ",aws_instance.bastion.public_ip,"-i .\\devOpsLab.pem","-l ec2-user"]) 
}