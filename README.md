# istio-install-scripts
istio install scripts and samples.

## Environment
* kubernetes cluster

## Install Istio
```bash
$ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/install_istio_on_k8s.sh | sh
```

## Remove Istio
```bash
$ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/remove_istio_on_k8s.sh | sh
```

## Telemetry
* install Servicegraph service
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/generating_service_graph.sh | sh
  ```

## Examples
* install bookinfo application
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/install_bookinfo_app.sh | bash
  ```

## Kubernetes
* [kubernetes nginx-ingress](https://github.com/tomoncle/istio-install-scripts/tree/master/samples/kubernetes/nginx-ingress)

* download images
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/k8s_image_download.py | python
  ```

* install ingress
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/install_ingress_for_kubernetes.sh | sh
  ```

* install dashboard
  ```bash
  $ curl -L https://raw.githubusercontent.com/tomoncle/istio-install-scripts/master/install/kubernetes/dashboard/kubernetes-dashboard.yaml | kubectl create -f - 
  ```
## FAQ & Link?
* [install ingress-nginx for helm](https://github.com/kubernetes/ingress-nginx/tree/0.10.0/deploy#using-helm) & [helm install Info](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
* [Kubernetes LoadBalancer](https://www.cnblogs.com/yuxiaoba/p/9212280.html)
* [kubernetes中服务的暴露访问方式（kubernetes ingress使用）](https://blog.csdn.net/newcrane/article/details/79092577)
* [kubernetes 服务发现与负载均衡](https://jimmysong.io/kubernetes-handbook/practice/service-discovery-and-loadbalancing.html)
* [kubernetes之Ingress部署](http://blog.51cto.com/newfly/2060587)
* [详解k8s组件Ingress边缘路由器并落地到微服务 - kubernetes](https://www.cnblogs.com/justmine/p/8991379.html)
