#!/bin/bash
sudo su


# Mount EBS volume
mkfs -t xfs ${device}
mkdir /home/${user}/${mount_dir}
mount ${device} /home/${user}/${mount_dir}


# Install Apache webserver
# yum -y install httpd
# sudo systemctl enable httpd
# sudo systemctl start httpd

# Upload website
# aws s3 cp ${bucket} /var/www/html --recursive


# Update environment for Python
yum update -y
yum install -y shadow-utils
yum groupinstall -y "Development Tools"
yum clean all
rm -rf /var/cache/yum

# Install new Python
amazon-linux-extras enable python3.${python3_version}
yum install -y python3.${python3_version}
yum install -y python3.${python3_version}-devel
yum install -y python3.${python3_version}-wheel
update-alternatives --install /usr/bin/python python /usr/bin/python3.${python3_version} 0
update-alternatives --install /usr/bin/pip pip /usr/bin/pip3.${python3_version} 0
yum clean all
rm -rf /var/cache/yum

# Upload web_app
mkdir /home/${user}/app
cd /home/${user}/app
aws s3 cp ${bucket}/${web_app_archive} .
unzip ${web_app_archive}
rm -f ${web_app_archive}

# Install and run
su ${user}
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

export AWS_DEFAULT_REGION=${region}
sudo python -m flask run --host 0.0.0.0 --port 80
