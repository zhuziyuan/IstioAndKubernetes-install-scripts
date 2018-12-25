#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/12/25 12:48
# @Author  : TOM.LEE
# @File    : k8s_token_map.py
# @Software: PyCharm
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

try:
    import commands
except ImportError:
    import subprocess as commands
from flask import Flask, jsonify, request

"""
这个文件是临时的接口，后期还需要优化设计.

部署：
    以 k8s DaemonSet方式部署, 如果需要高可用需要 service + ingress
"""

app = Flask(__name__)
API_PREFIX = '/api/v1'


@app.route('{}/namespaces'.format(API_PREFIX), methods=['POST'])
def kube_namespaces():
    namespace = request.form.get('namespace')
    if not namespace:
        return jsonify({'code': 400, 'body': '{}'.format('The namespace parameter is required')})
    cmd = """echo "
apiVersion: v1
kind: Namespace
metadata:
  name: {}
" | kubectl apply -f -""".format(namespace)
    (status, output) = commands.getstatusoutput(cmd)
    if status != 0:
        return jsonify({'code': 500, 'body': '{}'.format(output)})
    return jsonify({'code': 200, 'body': 'created'})


@app.route('{}/user'.format(API_PREFIX), methods=['POST'])
def kube_users():
    namespace = request.form.get('namespace') or 'default'
    username = request.form.get('username')
    if not username:
        return jsonify({'code': 400, 'body': '{}'.format('The username parameter is required')})

    cmd = """echo "
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    name: {username}
  name: {username}
  namespace: {namespace}
" | kubectl apply -f -""".format(username=username, namespace=namespace)
    (status, output) = commands.getstatusoutput(cmd)
    if status != 0:
        return jsonify({'code': 500, 'body': '{}'.format(output)})

    cmd = "kubectl -n %s describe secret $(kubectl -n %s get secret | grep %s | awk '{print $1}')| grep token:" % (
        namespace, namespace, username)
    (status, output) = commands.getstatusoutput(cmd)
    if status != 0 or not output:
        return jsonify({'code': 500, 'body': '{}'.format(output)})

    data = output.split(" ")
    return jsonify({'code': 200, 'body': 'created', 'token': data.pop()})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7070, debug=True)
