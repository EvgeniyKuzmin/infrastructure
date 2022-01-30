#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


# Update the system
yum update -y


# Install Python3
amazon-linux-extras enable python3.${python3_version}
yum install -y python3.${python3_version}
update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.${python3_version} 0
update-alternatives --install /usr/local/bin/pip3 pip3 /usr/bin/pip3.${python3_version} 0
rm -rf /var/cache/yum


# Download project's files
mkdir /home/${user}/app
cd /home/${user}/app
aws s3 cp ${bucket}/${web_app_archive} .
aws s3 cp ${bucket}/${app_name}.service .
unzip ${web_app_archive}
rm -f ${web_app_archive}


# Install project's dependencies
python3 -m venv .venv
source /home/${user}/app/.venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt


# Run the application as a service
cp ${app_name}.service /etc/systemd/system/
systemctl start ${app_name}.service
systemctl enable ${app_name}.service
systemctl status ${app_name}.service
