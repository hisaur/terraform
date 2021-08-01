#!/bin/bash
echo hello > /1.txt
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable --now nginx
chmod  --recursive 744 /usr/share/nginx/html