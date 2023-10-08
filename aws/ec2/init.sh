#!/bin/bash
yum install httpd -y
hostname > /var/www/html/index.html
echo ok > /var/www/html/health.html
systemctl restart httpd
systemctl enable httpd
