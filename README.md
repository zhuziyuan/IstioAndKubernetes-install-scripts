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
