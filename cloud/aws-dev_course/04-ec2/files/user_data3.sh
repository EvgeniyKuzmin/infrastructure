#!/bin/bash

# Mount EBS volume
# sudo mkfs -t xfs /dev/xvdf
# mkdir ~/shared_volume
# sudo mount /dev/xvdf ~/shared_volume


## Update the system
yum update -y


## Install a webserver
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service


## Install Python3
amazon-linux-extras enable python3.${python3_version}
yum install -y python3.${python3_version}
update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.${python3_version} 0
update-alternatives --install /usr/local/bin/pip3 pip3 /usr/bin/pip3.${python3_version} 0
rm -rf /var/cache/yum


## Download project's files
mkdir /home/${user}/app
cd /home/${user}/app
aws s3 cp ${bucket}/${web_app_archive} .
aws s3 cp ${bucket}/${app_name}.service .
unzip ${web_app_archive}
rm -f ${web_app_archive}

# mkdir /home/ec2-user/app
# cd /home/ec2-user/app
# aws s3 cp s3://evgenii-kuzmin-web-app/web_app.zip . >> /home/ec2-user/log.txt
# aws s3 cp s3://evgenii-kuzmin-web-app/flask-app.service .
# unzip web_app.zip
# rm -f web_app.zip


## Install project's dependencies
# python3 -m venv .venv
# source /home/${user}/app/.venv/bin/activate
# pip install --upgrade pip >> /home/ec2-user/log.txt
# pip install -r requirements.txt >> /home/ec2-user/log.txt

# python3 -m venv .venv >> /home/ec2-user/log.txt
# # source /home/ec2-user/app/.venv/bin/activate
# pip /home/ec2-user/app/.venv/bin/pip --upgrade pip >> /home/ec2-user/log.txt
# pip /home/ec2-user/app/.venv/bin/pip -r requirements.txt >> /home/ec2-user/log.txt

pip3 --upgrade pip >> /home/ec2-user/log.txt
pip3 -r requirements.txt >> /home/ec2-user/log.txt
pip3 freeze >> /home/ec2-user/log.txt



## Run the applications as a service
cp ${app_name}.service /etc/systemd/system/ >> /home/ec2-user/log.txt
systemctl start ${app_name}.service >> /home/ec2-user/log.txt 
systemctl enable ${app_name}.service >> /home/ec2-user/log.txt
