#! /bin/bash

# tomoncle 2018-12-12
if [ -z "$ISTIO_PATH" ];then
   echo "... WARNING ..."
   echo "环境变量 \$ISTIO_PATH 不存在，请刷新 ~/.bashrc 后重试."
   echo "...  exit0  ..."
   exit
fi

cd $ISTIO_PATH
# 只支持集群用的是手工 Sidecar 注入
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

# 给应用定义 Ingress gateway
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# get pod and svc
echo -e "\n# kubectl get services"
kubectl get services
echo -e "\n# kubectl get pods"
kubectl get pods
echo -e "\n# kubectl get gateway"
kubectl get gateway

# ************************************ 配置 Istio 以使用 Istio 在服务网格外部公开服务 Gateway *******************************************
#################### 使用外部负载均衡器 #####################
# 使用外部负载均衡器时确定 IP 和端口
#export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
#export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
#export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
# 在某些环境中，外部负载均衡器可能需要使用主机名而不是 IP 地址
#export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

####################      NodePort    ######################
# 确定使用 Node Port 时的 ingress IP 和端口
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=NodeIp

# 设置 GATEWAY_URL
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo -e "\n Installed bookinfo application . Let's try it."
echo "************** GATEWAY_URL : $GATEWAY_URL"
echo '**************    TEST     : $ curl http://$GATEWAY_URL/productpage'
