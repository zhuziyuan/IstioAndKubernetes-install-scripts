#! /bin/bash

# https://docs.docker.com/install/linux/docker-ce/centos/
echo -e "\033[5;36mremove system config ...\033[0m"
sleep 2
yum remove -y docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

echo -e "\033[5;36minstall storage driver and required packages ...\033[0m"
sleep 2 
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

echo -e "\033[5;36minstall stable repository ...\033[0m"
sleep 2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# get last version of 18
# yum list docker-ce --showduplicates | sort -r
version=`yum list docker-ce --showduplicates| awk '{print $2}'| grep '^18.' | sort -r | awk 'NR==1{print}'`

echo -e "\033[5;36minstall docker version: docker-ce-$version\033[0m"
sleep 2
yum install -y "docker-ce-$version"

echo -e "\033[5;36minstall success !!!\033[0m"
docker version
