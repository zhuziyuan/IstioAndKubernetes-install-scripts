#! /bin/bash

# tomoncle 2018-12-12
########## Install Istio For Kubernetes ###############

echo "
Istio 对 Pod 和服务的要求
要成为服务网格的一部分，Kubernetes 集群中的 Pod 和服务必须满足以下几个要求：

1. 需要给端口正确命名：服务端口必须进行命名。端口名称只允许是<协议>[-<后缀>-]模式，其中<协议>部分可选择范围包括
http、http2、grpc、mongo 以及 redis，Istio 可以通过对这>些协议的支持来提供路由能力。
例如 name: http2-foo 和 name: http 都是有效的端口名，但 name: http2foo 就是无效的。
如果没有给端口进行命名，或者命名没有使用指定前缀，那么这一端口的流量就会被视为普通 TCP 流量（除非显式的用 Protocol: UDP 声明该端口是 UDP 端口）。

2. 关联服务：Pod 必须关联到 Kubernetes 服务，如果一个 Pod 属于多个服务，这些服务不能再同一端口上使用不同协议，例如 HTTP 和 TCP。

3. Deployment 应带有 app 以及 version 标签：在使用 Kubernetes Deployment 进行 Pod 部署的时候，
建议显式的为 Deployment 加上 app 以及 version 标签。每个 Deployment 都应该有一个有意义的 app 标签和一个用于标识 Deployment 版本的 version 标签。
app 标签在分布式跟踪的过程中会被用来加入上下文信息。Istio 还会用 app 和 version 标签来给遥测指标数据加入上下文信息。
"

ISTIO_HOME=/usr/local/istio
HELM_HOME=/usr/local/helm

$ISTIO_HOME/istioctl version > /dev/null 2>&1

if [ $? -ne 0 ];then
    # download install scripts
    #wget https://raw.githubusercontent.com/istio/istio/master/release/downloadIstioCandidate.sh
    cat << EOF > downloadIstioCandidate.sh
#!/bin/sh
#
# Early version of a downloader/installer for Istio
#
# This file will be fetched as: curl -L https://git.io/getLatestIstio | sh -
# so it should be pure bourne shell, not bash (and not reference other scripts)
#
# The script fetches the latest Istio release candidate and untars it.
# It's derived from ../downloadIstio.sh which is for stable releases but lets
# users do curl -L https://git.io/getLatestIstio | ISTIO_VERSION=0.3.6 sh -
# for instance to change the version fetched.

# This is the latest release candidate (matches ../istio.VERSION after basic
# sanity checks)

OS="\$(uname)"
if [ "x\${OS}" = "xDarwin" ] ; then
  OSEXT="osx"
else
  # TODO we should check more/complain if not likely to work, etc...
  OSEXT="linux"
fi

if [ "x\${ISTIO_VERSION}" = "x" ] ; then
  ISTIO_VERSION=\$(curl -L -s https://api.github.com/repos/istio/istio/releases/latest | \
                  grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/")
fi

NAME="istio-\$ISTIO_VERSION"
URL="https://github.com/istio/istio/releases/download/\${ISTIO_VERSION}/istio-\${ISTIO_VERSION}-\${OSEXT}.tar.gz"
echo "Downloading \$NAME from \$URL ..."
curl -L "\$URL" | tar xz
# TODO: change this so the version is in the tgz/directory name (users trying multiple versions)
echo "Downloaded into \$NAME:"
ls "\$NAME"
BINDIR="\$(cd "\$NAME/bin" && pwd)"
#echo "Add \$BINDIR to your path; e.g copy paste in your shell and/or ~/.profile:"
#echo "export PATH=\"\$PATH:\$BINDIR\""
EOF

    chmod +x downloadIstioCandidate.sh
    sh downloadIstioCandidate.sh
    mv istio* /usr/local/istio

    cat << EOF >> $HOME/.bashrc

# add istio path
export ISTIO_PATH=$ISTIO_HOME
export PATH=\$ISTIO_HOME/bin:\$PATH
EOF

    # version
    rm -f downloadIstioCandidate.sh
    echo "************* Replace the default installation location **********************"
    echo "ISTIO INSTALL PATH: "$ISTIO_HOME
    $ISTIO_HOME/bin/istioctl version
    echo "******************************************************************************"
    sleep 1
else
    echo "************* Istio already exists **********************"
    echo "ISTIO INSTALL PATH: "$ISTIO_HOME
    $ISTIO_HOME/bin/istioctl version
    echo "*********************************************************"
    sleep 1
fi

# 刷新环境变量
source ~/.bashrc > /dev/null 2>&1

# download helm
$HELM_HOME/helm version > /dev/null 2>&1

if [ $? -eq 127 ];then
    curl -L https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz | tar xz && mv linux-amd64/ /usr/local/helm

    cat << EOF >> $HOME/.bashrc

# add helm path
export PATH=/usr/local/helm:\$PATH
EOF

    echo -e "\n************* Helm the default installation location **********************"
    echo "HELM INSTALL PATH: "$HELM_HOME
    $HELM_HOME/helm version
    echo -e "\n***************************************************************************"
    sleep 1
else
    echo -e "\n************* Helm  already  exists **********************"
    echo "HELM INSTALL PATH: "$HELM_HOME
    $HELM_HOME/helm version
    echo -e "\n**********************************************************"
    sleep 1
fi


$HELM_HOME/helm version > /dev/null 2>&1
if [ $? -eq 127 ];then 
    echo '安装失败, 重新执行该脚本即可.'
    exit
fi
#echo "安装 Istio 的自定义资源定义（CRD）"
#kubectl apply -f $ISTIO_PATH/install/kubernetes/helm/istio/templates/crds.yaml

echo -e "\n***************通过 Helm 和 Tiller 的 helm install 安装 Istio******************"
echo -e "\n为 Tiller 配置 service account"
kubectl apply -f $ISTIO_HOME/install/kubernetes/helm/helm-service-account.yaml
sleep 1

echo -e  "\n使用 service account 在kubernetes集群中安装 Tiller (helm server)."
$HELM_HOME/helm init --service-account tiller

while true
do
    echo "check helm server install status..."
    sleep 5
    tillerNum=`kubectl get po -n kube-system -l name=tiller | grep tiller| wc -l`
    if [ $tillerNum -ge 1 ];
    then
       break
    fi
done

echo "helm server created successfully."
sleep 1

echo -e "\n安装 Istio"
#helm repo add istio.io "https://storage.googleapis.com/istio-prerelease/daily-build/master-latest-daily/charts"
#helm dep update $ISTIO_HOME/install/kubernetes/helm/istio
# 默认
# helm install $ISTIO_HOME/install/kubernetes/helm/istio --name istio --namespace istio-system 

# 如果想启用全局双向 TLS，请将 global.mtls.enabled 设置为 true
# helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set global.mtls.enabled=true

# 默认情况下，Istio 使用 负载均衡器 服务对象类型。有些平台不支持 负载均衡器 服务对象类型。
# 对于缺少 负载均衡器 支持的平台，安装需要带有 “NodePort” 支持的 Istio
$HELM_HOME/helm install $ISTIO_HOME/install/kubernetes/helm/istio \
     --name istio \
     --namespace istio-system \
     --set gateways.istio-ingressgateway.type=NodePort \
     --set gateways.istio-egressgateway.type=NodePort

# 刷新环境变量
source ~/.bashrc > /dev/null 2>&1
echo "install istio ok!"
