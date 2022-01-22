#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


# Update the system
yum update -y


# Install Python3
amazon-linux-extras enable python3.8
yum install -y python3.8
update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.8 0
update-alternatives --install /usr/local/bin/pip3 pip3 /usr/bin/pip3.8 0
rm -rf /var/cache/yum


# Download project's files
mkdir /home/ec2-user/app
cd /home/ec2-user/app
aws s3 cp s3://evgenii-kuzmin-web-app/web_app.zip .
aws s3 cp s3://evgenii-kuzmin-web-app/flask-app.service .
unzip web_app.zip
rm -f web_app.zip


# Install project's dependencies
python3 -m venv .venv
source /home/ec2-user/app/.venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt


# Run the application as a service
cp flask-app.service /etc/systemd/system/
systemctl start flask-app.service
systemctl enable flask-app.service
systemctl status flask-app.service
