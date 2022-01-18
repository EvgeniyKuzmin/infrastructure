#!/bin/bash

yum update -y

yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service

amazon-linux-extras enable python3.8
yum install -y python3.8
update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.8 0
update-alternatives --install /usr/local/bin/pip3 pip3 /usr/bin/pip3.8 0
rm -rf /var/cache/yum

cd /home/ec2-user/app

pip3 install --upgrade pip
pip3 install -r requirements.txt
