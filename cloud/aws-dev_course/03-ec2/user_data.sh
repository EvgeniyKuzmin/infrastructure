
#!/bin/bash
sudo su

# Install Apache webserver
yum -y install httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# Upload website
aws s3 cp ${bucket} /var/www/html --recursive
}