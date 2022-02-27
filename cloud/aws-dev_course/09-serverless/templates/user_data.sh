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
aws s3 cp ${bucket}/app.service .
aws s3 cp ${bucket}/${credential_file} .
unzip ${web_app_archive}
rm -f ${web_app_archive}


# Install project's dependencies
python3 -m venv .venv
source /home/${user}/app/.venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
mkdir uploads
chmod 777 uploads  # TODO: maybe we can delete it

# Initialize DB
flask db upgrade


# Run the application as a service
cp app.service /etc/systemd/system/
systemctl start app.service
systemctl enable app.service
systemctl status app.service
