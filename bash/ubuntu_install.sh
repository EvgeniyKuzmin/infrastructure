#!/bin/bash

EMAIL="evgeniy.a.kuzmin@gmail.com"
NAME="EvgeniyKuzmin"

### Unpdate system's packages
echo "---=== Updating ===---"
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y


### Install usefull utilites
# make - describing relations of files
# wget - downloading files by HTTP, HTTP, FTP
# curl - working with URL requests (send, download, etc.)
# xclip - command line interface for working with clipboard
# tk-dev - cross-platform graph toolkit for Tcl and X11
echo "---=== Install common packages ===---"
sudo apt install -y \
	make \
	wget \
	curl \
	xclip \
	tk-dev


### Install software
echo "---=== Install software via snap ===---"
sudo snap install sublime-text --classic
sudo snap install \
	bitwarden \
	postman \
	beekeeper-studio \
	clementine \
	vlc \
	libreoffice \
	chromium \
	telegram-desktop \
	skype \
	teams \
	zoom-client


### Install GIT
echo "---=== Install GIT ===---"
sudo apt install -y git
git config --global user.name $NAME
git config --global user.email $EMAIL
git config --global core.editor subl
## 1. Generating a new SSH key
# $ ssh-keygen -t "github_${NAME}" -C $EMAIL
## 2. Adding the new SSH key to the ssh-agent
# $ eval "$(ssh-agent -s)"
# $ ssh-add "~/.ssh/github_${NAME}"
## 3. Adding a new SSH key to your GitHub account
# GitHub.com > Settings > SSH and GPG keys > Add SSH key
# "Title": empty, "Key": content of "~/.ssh/github_${NAME}.pub"
## 4. Test your SSH connection
# $ ssh -T git@github.com


### Install Python
echo "---=== Install Python ===---"
sudo apt install -y \
	python3-pip \
	python3-dev \
	python3-venv \
	build-essential \
	libssl-dev \
	libffi-dev \
	unixodbc-dev


### Install PyEnv
echo "---=== Install PyEnv ===---"
sudo apt install -y --no-install-recommends \
	make \
	build-essential \
	libssl-dev \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	wget \
	curl \
	llvm \
	libncurses5-dev \
	xz-utils \
	tk-dev \
	libxml2-dev \
	libxmlsec1-dev \
	libffi-dev \
	liblzma-dev

curl https://pyenv.run | bash
git clone \
	https://github.com/pyenv/pyenv-virtualenv.git \
	$(pyenv root)/plugins/pyenv-virtualenv

echo '' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '### Pyenv settings' >> ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"'  >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"'  >> ~/.bashrc
echo 'eval "$(pyenv init -)"'  >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"'  >> ~/.bashrc

exec $SHELL


### Docker install
echo "---=== Install Docker ===---"
sudo apt install -y \
	curl \
	apt-transport-https \
	ca-certificates \
	gnupg-agent \
	software-properties-common


curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
	| sudo apt-key add -

sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"

sudo apt update

sudo apt install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io

# To launch command without `sudo`, need to add user to `docker` group 
sudo usermod -aG docker ${USER}
su - ${USER}

# Install docker-compose
sudo curl -L \
	"https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" \
	-o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


### Install Dropbox
echo '---=== Install Dropbox ===---'
cd ~

wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" \
	| tar xzf -

~/.dropbox-dist/dropboxd


### Install MS ODBC
sudo su
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/19.10/prod.list > /etc/apt/sources.list.d/mssql-release.list
exit

# sudo apt full-upgrade -y
sudo apt update -y
sudo ACCEPT_EULA=Y apt install \
	msodbcsql17 \
	mssql-tools \
	unixodbc-dev


echo '' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '### MSSQL settings' >> ~/.bashrc
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

source ~/.bashrc


# Install AWS
echo "--->>> Install AWS"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "--->>> AWS installed: \"$(aws --version)\""


# Install AWS-Vault
echo "--->>> Install AWS-Vault"
sudo curl -L -o /usr/local/bin/aws-vault https://github.com/99designs/aws-vault/releases/download/v6.2.0/aws-vault-linux-amd64
sudo chmod 755 /usr/local/bin/aws-vault
echo "--->>> Severless installed: \"$(aws-vault --version)\""
# To add rcom apply the following and specify aws creds
# aws-vault add rcom


# Install NodeJS, NPM
echo "--->>> Install NodeJS"
sudo apt install nodejs
echo "--->>> NodeJS installed: \"$(nodejs -v)\""

echo "--->>> Install NPM"
sudo apt install npm
echo "--->>> NPM installed: \"$(npm -v)\""


# Install Serverless
echo "--->>> Install Serverless"
npm install -g serverless
echo "--->>> Severless installed: \"$(serverless --version)\""


echo "--->>> Install OPSWAT Client"
wget https://s3-us-west-2.amazonaws.com/opswat-gears-cloud-clients/linux_installer/latest/opswatclient_deb.tar
tar -xvf opswatclient_deb.tar
cd opswatclient_deb
sudo ./setup.sh -s=3445 -l=835dc08839b78a925c9f8882b85b3592
sudo rm -rf opswatclient_deb
sudo rm opswatclient_deb.tar
echo "--->>> Installiation of OPSWAT Client is complite"


echo "--->>> Install Ansible"
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
echo "--->>> Installiation of Ansible is complite"
