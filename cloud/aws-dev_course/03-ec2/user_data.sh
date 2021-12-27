
#!/bin/bash
sudo su

# Install Apache webserver
yum -y install httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# Upload website
aws s3 cp ${bucket} /var/www/html --recursive

# Mount EBS volume
mkfs -t xfs ${device}
mkdir /home/${user}/${mount_dir}
mount ${device} /home/${user}/${mount_dir}
