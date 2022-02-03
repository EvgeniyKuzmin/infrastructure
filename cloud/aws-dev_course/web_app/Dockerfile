FROM amazonlinux:2

ARG PYTHON3_VERSION=8

EXPOSE 4000

COPY ["requirements.txt", "/home/ec2-user/app/"]

RUN yum update -y

RUN amazon-linux-extras enable python3.${PYTHON3_VERSION} && \
    yum install -y python3.${PYTHON3_VERSION} && \
    update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.${PYTHON3_VERSION} 0 && \
    update-alternatives --install /usr/local/bin/pip3 pip3 /usr/bin/pip3.${PYTHON3_VERSION} 0 && \
    rm -rf /var/cache/yum

WORKDIR /home/ec2-user/app

RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt
