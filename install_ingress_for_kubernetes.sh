#! /bin/sh

# tomoncle
# install kuberentes ingress network 
# docs: https://github.com/kubernetes/ingress-nginx/tree/0.10.0/deploy

IG_PATH=/tmp/k8s_ingress_yaml
if [ ! -d $IG_PATH ];then
    mkdir -p $IG_PATH
fi

## create namespace
cat << EOF > $IG_PATH/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
EOF

kubectl apply -f $IG_PATH/namespace.yaml

## create default-backend
cat << EOF > $IG_PATH/default-backend.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app: default-http-backend
  namespace: ingress-nginx
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: default-http-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        # Any image is permissable as long as:
        # 1. It serves a 404 page at /
        # 2. It serves 200 on a /healthz endpoint
        image: tomoncle/gcr.io_00_google_containers_00_defaultbackend:1.4 #gcr.io/google_containers/defaultbackend:1.4
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
---

apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: ingress-nginx
  labels:
    app: default-http-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: default-http-backend
EOF

kubectl apply -f $IG_PATH/default-backend.yaml

## create configmap
cat << EOF > $IG_PATH/configmap.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app: ingress-nginx
EOF

kubectl apply -f $IG_PATH/configmap.yaml

## create tcp-services-configmap
cat << EOF > $IG_PATH/tcp-services-configmap.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: tcp-services
  namespace: ingress-nginx
EOF

kubectl apply -f $IG_PATH/tcp-services-configmap.yaml

## create udp-services-configmap
cat << EOF > $IG_PATH/udp-services-configmap.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: udp-services
  namespace: ingress-nginx
EOF

kubectl apply -f $IG_PATH/udp-services-configmap.yaml

## create rbac (role)
cat << EOF > $IG_PATH/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
  namespace: ingress-nginx

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: nginx-ingress-clusterrole
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
        - events
    verbs:
        - create
        - patch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses/status
    verbs:
      - update

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: nginx-ingress-role
  namespace: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - configmaps
    resourceNames:
      # Defaults to "<election-id>-<ingress-class>"
      # Here: "<ingress-controller-leader>-<nginx>"
      # This has to be adapted if you change either parameter
      # when launching the nginx-ingress-controller.
      - "ingress-controller-leader-nginx"
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - get

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: nginx-ingress-role-nisa-binding
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress-role
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-nginx

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: nginx-ingress-clusterrole-nisa-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-ingress-clusterrole
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-nginx
EOF

kubectl apply -f $IG_PATH/rbac.yaml

## with-rbac (nginx-ingress-controller )
cat << EOF > $IG_PATH/with-rbac.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx 
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingress-nginx
  template:
    metadata:
      labels:
        app: ingress-nginx
      annotations:
        prometheus.io/port: '10254'
        prometheus.io/scrape: 'true'
    spec:
      serviceAccountName: nginx-ingress-serviceaccount
      hostNetwork: true # 添加该字段，暴露nginx-ingress-controller pod的服务端口
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.10.0
          args:
            - /nginx-ingress-controller
            - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
            - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
            - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
            - --annotations-prefix=nginx.ingress.kubernetes.io
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
          - name: http
            containerPort: 80
          - name: https
            containerPort: 443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
EOF

kubectl apply -f $IG_PATH/with-rbac.yaml

echo "\n 
***************************************** Test Ingress *****************************************
注意测试时，要么以curl -H 的方式，要么要配置访问客户端所在机器的hosts文件(任意一台node_ip 域名1 域名2 域名3 ...)，或配置DNS

$ cat webapp.yaml

---

apiVersion: v1
kind: ReplicationController
metadata:
  name: rc-webapp
  labels:
    name: tom-test-webapp
spec:
  replicas: 2
  selector:
    name: webapp
  template:
    metadata:
      labels:
        name: webapp
    spec:
        containers:
        - name: webapp
          image: tomoncle/webapp
          env:
            - name: DB_HOST
              value: "mysql-service"
            - name: DB_PORT
              value: "3306"
          ports:
            - containerPort: 5000
---

apiVersion: v1
kind: Service
metadata:
  name: svc-webapp
  labels:
    name: tom-test-webapp
spec:
  type: NodePort
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 5000
    nodePort: 31115
  selector:
    name: webapp



$ cat webapp-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: webapp-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: ingress.webapp.com
    http:
      paths:
      - backend:
          serviceName: svc-webapp
          servicePort: 5000


$ kubectl create -f webapp.yaml
$ kubectl create -f webapp-ingress.yaml
$ curl localhost -H "host:ingress.webapp.com"
"
