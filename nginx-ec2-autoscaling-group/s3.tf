resource "aws_s3_bucket" "terraform" {
    bucket = "terraform-toktosunov-s3"
    acl    = "private"
    tags   = {
    "Creator" = "Terraform"
    "Environment" = var.env
  }
}
resource "aws_s3_bucket_object" "terraform-index" {
  key    = "index.html"
  bucket = aws_s3_bucket.terraform.id
  source = local_file.index_html.filename
}
resource "aws_s3_bucket_object" "terraform-error" {
  key    = "error.html"
  bucket = aws_s3_bucket.terraform.id
  source = local_file.error_html.filename
}
resource "local_file" "index_html" {
    content     = "<Html><title>Sample Nginx Web Page</title><b>Hello World</b><i>Hello World</i><u> Hello World</u></Html>"
    filename    = "${path.module}/index.html"
}
resource "local_file" "error_html" {
    content     = "<Html><title>Sample Nginx Error Page</title><b>Error</b><i>Error</i><u>Error</u></Html>"
    filename    = "${path.module}/error.html"
}