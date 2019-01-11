# istio & kubernetes install-scripts
istio & kubernetes install scripts and samples.

# Istio
* environment: `kubernetes cluster`
* install:
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/istio_install_on_k8s.sh | sh
  ```
* remove:
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/istio_remove_on_k8s.sh | sh
  ```

### Telemetry
* install Servicegraph service
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/istio_generating_service_graph.sh | sh
  ```

### Examples
* install bookinfo application
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/istio_install_bookinfo_app.sh | bash
  ```

# Kubernetes
* [kubernetes nginx-ingress](https://github.com/tomoncle/IstioAndKubernetes-install-scripts/tree/master/samples/kubernetes/nginx-ingress)

* download images
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/k8s_image_download.py | python
  ```

* install ingress (hostNetwork)
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/k8s_install_ingress.sh | sh
  ```
  
* install ingress (NodePort)
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/k8s_install_ingress2.sh | sh
  ```

* install dashboard
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/IstioAndKubernetes-install-scripts/master/install/kubernetes/dashboard/kubernetes-dashboard.yaml | kubectl create -f - 
  ```

## FAQ & Link & Help
* [install ingress-nginx for helm](https://github.com/kubernetes/ingress-nginx/tree/0.10.0/deploy#using-helm) & [helm install Info](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
* [Kubernetes LoadBalancer](https://www.cnblogs.com/yuxiaoba/p/9212280.html)
* [kubernetes中服务的暴露访问方式（kubernetes ingress使用）](https://blog.csdn.net/newcrane/article/details/79092577)
* [kubernetes 服务发现与负载均衡](https://jimmysong.io/kubernetes-handbook/practice/service-discovery-and-loadbalancing.html)
* [kubernetes之Ingress部署](http://blog.51cto.com/newfly/2060587)
* [详解k8s组件Ingress边缘路由器并落地到微服务 - kubernetes](https://www.cnblogs.com/justmine/p/8991379.html)
* [source-ip-for-services-with-type-loadbalancer](https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-loadbalancer)
* [Dashboard UI](https://github.com/smpio/kubernator)