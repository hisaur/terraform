resource "aws_iam_role" "terraform" {
  name = "terraform-s3-read-only"
  assume_role_policy = jsonencode(
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
})
}
resource "aws_iam_policy" "terraform" {
  name = "terraform-s3-read-only"
  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "*"
        }
    ]
})
  tags = {
    "Creator" = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_iam_policy_attachment" "terraform" {
  name       = "test-attachment"
  roles      = [aws_iam_role.terraform.name]
  policy_arn = aws_iam_policy.terraform.arn
}
resource "aws_iam_instance_profile" "terraform" {
  name  = "terraform-s3-read-only"
  role = aws_iam_role.terraform.name
}