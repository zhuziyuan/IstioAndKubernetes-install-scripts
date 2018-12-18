#! /bin/sh

# tomoncle 2018-12-13
#########################  生成服务图 #########################

if [ -z "$ISTIO_PATH" ];then
   echo "... WARNING ..."
   echo "环境变量 \$ISTIO_PATH 不存在，请刷新 ~/.bashrc 后重试."
   echo "...  exit0  ..."
   exit
fi

# 安装 Servicegraph 附加组件
curl -sSL https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/install/kubernetes/addons/servicegraph.yaml | kubectl apply -f -
#kubectl apply -f $ISTIO_PATH/install/kubernetes/addons/servicegraph.yaml


# 验证服务是否在集群中运行
echo -e "\n# \033[5;31mkubectl -n istio-system get svc servicegraph\033[0m"
kubectl -n istio-system get svc servicegraph

# 验证pod
echo -e "\n# \033[5;31mkubectl -n istio-system get pod -l app=servicegraph\033[0m"
kubectl -n istio-system get pod -l app=servicegraph

echo -e "\n\n\033[32m******************************install success!*******************************\033[0m"

echo -e "\n\033[34m
** 测试流量发送到网格
  
    对于 Bookinfo 示例，请在 Web 浏览器中访问 http://\$GATEWAY_URL/productpage

** 代理 Servicegraph UI 访问
   
   \$ kubectl -n istio-system port-forward \$(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088 &
   在 Web 浏览器中访问 http://localhost:8088/force/forcegraph.html 或 http://NodeIp:35009/force/forcegraph.html

** 试验查询参数:
   
   在Web浏览器中访问http://localhost:8088/force/forcegraph.html?time_horizon=15s&filter_empty=true, 请注意提供的查询参数。
   filter_empty=true 将仅显示当前在时间范围内接收流量的服务。
   time_horizon=15s 影响上面的过滤器，并且还会在单击服务时影响报告的流量信息, 交通信息将在指定的时间范围内汇总。
   默认行为是不过滤空服务，并使用5分钟的时间范围。
   
** Servicegraph 服务提供端点，用于生成和可视化网格内的服务图, 它公开了以下端点：

   /force/forcegraph.html 如上所述，这是一个交互式D3.js 可视化。
   /dotviz 是一个静态的Graphviz 可视化。
   /dotgraph 提供DOT序列化。
   /d3graph 为 D3 可视化提供了 JSON 序列化。
   /graph 提供通用的 JSON 序列化。
   所有端点都采用上面探讨的查询参数(time_horizon=15s 和 filter_empty=true)。
   
** Servicegraph 示例建立在 Prometheus 查询之上，取决于标准的 Istio 度量标准配置。

\033[0m"

#删除 Servicegraph 附加组件
#kubectl delete -f $ISTIO_PATH/install/kubernetes/addons/servicegraph.yaml
#curl -sSL https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/install/kubernetes/addons/servicegraph.yaml | kubectl delete -f -
