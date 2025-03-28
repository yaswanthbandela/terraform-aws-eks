#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0")
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user."
fi

# Update and install required packages
apt update -y && apt upgrade -y
VALIDATE $? "System update"

# Install Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
VALIDATE $? "Docker installation"

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
eksctl version
VALIDATE $? "eksctl installation"

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
VALIDATE $? "kubectl installation"

# Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
VALIDATE $? "Helm installation"

# Install MySQL client
apt install -y mysql-client
VALIDATE $? "MySQL client installation"

# Install kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installation"
