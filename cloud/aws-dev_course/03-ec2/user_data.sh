#!/bin/bash

# Mount EBS volume
sudo mkfs -t xfs /dev/xvdf
mkdir ~/shared_volume
sudo mount /dev/xvdf ~/shared_volume

# Update environment for Python
sudo yum update -y
sudo yum groupinstall -y "Development Tools"

# Install new Python
sudo amazon-linux-extras enable python3.8
sudo yum install -y python3.8
sudo update-alternatives --install /usr/local/bin/python python /usr/bin/python3.8 0
sudo update-alternatives --install /usr/localbin/pip pip /usr/bin/pip3.8 0

# curl -O https://bootstrap.pypa.io/get-pip.py
# sudo python get-pip.py
# sudo update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.8 0
# sudo yum -y install python-pip
# yum search pip

# sudo yum clean all
sudo rm -rf /var/cache/yum

# Upload web_app
mkdir ~/app && cd ~/app
aws s3 cp s3://evgenii-kuzmin-web-app/web_app.zip .
unzip web_app.zip
rm -f web_app.zip

# Install and run
# python -m venv .venv
# source .venv/bin/activate

sudo pip install --upgrade pip

python -m pip install --upgrade pip
python -m pip install -r requirements.txt
export AWS_DEFAULT_REGION=eu-west-1
python -m flask run --host 0.0.0.0 --port 80



###############################################################################


# #!/bin/bash
# sudo su


# # Mount EBS volume
# mkfs -t xfs ${device}
# mkdir /home/${user}/${mount_dir}
# mount ${device} /home/${user}/${mount_dir}


# # Install Apache webserver
# # yum -y install httpd
# # sudo systemctl enable httpd
# # sudo systemctl start httpd

# # Upload website
# # aws s3 cp ${bucket} /var/www/html --recursive


# # Update environment for Python
# yum update -y
# yum install -y shadow-utils
# yum groupinstall -y "Development Tools"
# yum clean all
# rm -rf /var/cache/yum

# # Install new Python
# amazon-linux-extras enable python3.${python3_version}
# yum install -y python3.${python3_version}
# yum install -y python3.${python3_version}-devel
# yum install -y python3.${python3_version}-wheel
# update-alternatives --install /usr/bin/python python /usr/bin/python3.${python3_version} 0
# update-alternatives --install /usr/bin/pip pip /usr/bin/pip3.${python3_version} 0
# yum clean all
# rm -rf /var/cache/yum

# # Upload web_app
# mkdir /home/${user}/app
# cd /home/${user}/app
# aws s3 cp ${bucket}/${web_app_archive} .
# unzip ${web_app_archive}
# rm -f ${web_app_archive}

# # Install and run
# python -m pip install --upgrade pip
# su ${user}
# export PATH="$PATH:/home/ec2-user/.local/bin"
# python -m pip install -r requirements.txt
# export AWS_DEFAULT_REGION=${region}
# python -m flask run --host 0.0.0.0 --port 5000
