#! /bin/sh

yum install epel-release -y && \
  yum update && \
  yum install python -y && \
  yum install git python-pip -y && \
  pip install pip --upgrade -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com && \
  pip install --no-cache-dir ansible -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com && \
  git clone https://github.com/tomoncle/kubeasz.git && \
  mkdir -p /etc/ansible && \
  mv kubeasz/* /etc/ansible -f

echo "config success!!!"
echo "

++++++++++++++++++++++++++++++++++++++++++++++++++++
             ******   NETX  ******

1.download k8s.*.tar.gz
  $ tar zxvf k8s.*.tar.gz
  $ mv bin/* /etc/ansible/bin -f

2.configuration
  $ ssh-keygen -t rsa -b 2048
  $ ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.137.142

  $ cd /etc/ansible && cp example/hosts.m-masters.example hosts
  $ ansible all -m ping 
  $ ansible-playbook 90.setup.yml
++++++++++++++++++++++++++++++++++++++++++++++++++++

"
