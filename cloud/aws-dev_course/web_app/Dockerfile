FROM amazonlinux:2

EXPOSE 4000

COPY ["user_data.sh", "/home/ec2-user/"]
COPY ["requirements.txt", "/home/ec2-user/app/"]

RUN bash /home/ec2-user/user_data.sh
WORKDIR /home/ec2-user/app
