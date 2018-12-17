# 配置目标地址重定向(302 redirect)

### 配置app-root
> 访问 `http://ingress.bookinfo.com` 自动跳转到 `http://ingress.bookinfo.com/force/forcegraph.html`

* 创建
```bash
$ cat << EOF > bookinfo-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: bookinfo-ingress
  namespace: istio-system
  annotations:
    #kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/app-root: /force/forcegraph.html
spec:
  rules:
  - host: ingress.bookinfo.com
    http:
      paths:
      - backend:
          serviceName: servicegraph
          servicePort: 8088
        path: /
EOF

$ kubectl create -f bookinfo-ingress.yaml
```
* 测试
```bash
[root@master2 bookinfo]# curl -v http://localhost -H "host:ingress.bookinfo.com"
* About to connect() to localhost port 80 (#0)
*   Trying ::1...
* Connected to localhost (::1) port 80 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Accept: */*
> host:ingress.bookinfo.com
> 
< HTTP/1.1 302 Moved Temporarily
< Server: nginx/1.13.8
< Date: Mon, 17 Dec 2018 09:26:10 GMT
< Content-Type: text/html
< Content-Length: 161
< Location: http://ingress.bookinfo.com/force/forcegraph.html
< Connection: keep-alive
< 
<html>
<head><title>302 Found</title></head>
<body bgcolor="white">
<center><h1>302 Found</h1></center>
<hr><center>nginx/1.13.8</center>
</body>
</html>
* Connection #0 to host localhost left intact
```
