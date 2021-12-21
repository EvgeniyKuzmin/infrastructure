
#!/bin/bash
sudo su
yum -y install httpd
echo "<h1>Kuzmin Evgenii</h1>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd
