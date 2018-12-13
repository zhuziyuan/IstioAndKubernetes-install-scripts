#! /bin/bash

# tomoncle 2018-12-12
###############################  卸载Istio ###################################

# 卸载通过 Helm 的 helm template 安装 Istio
# kubectl delete -f $HOME/istio.yaml

# 卸载通过 Helm 和 Tiller 的 helm install 安装 Istio
helm delete --purge istio

# 如果您的 Helm 版本低于 2.9.0，那么在重新部署新版 Istio chart 之前，您需要手动清理额外的 job 资源
# kubectl -n istio-system delete job --all

# 可以删除 CRD
kubectl delete -f $ISTIO_PATH/install/kubernetes/helm/istio/templates/crds.yaml > /dev/null 2>&1
