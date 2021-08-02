#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable --now nginx
aws s3 cp s3://${bucket_name}/${index_key} /usr/share/nginx/html
aws s3 cp s3://${bucket_name}/${error_key} /usr/share/nginx/html
chown  --recursive nginx:nginx /usr/share/nginx/html
chmod  --recursive 744 /usr/share/nginx/html
