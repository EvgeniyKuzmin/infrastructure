yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service

systemctl start flask-app.service
systemctl enable flask-app.service
systemctl status flask-app.service >> /home/ec2-user/log.txt