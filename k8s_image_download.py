#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

try:
    import commands
except ImportError:
    import subprocess as commands


image_data = """tomoncle/gcr.io_00_linkerd-io_00_proxy:stable-2.1.0
tomoncle/gcr.io_00_linkerd-io_00_grafana:stable-2.1.0
tomoncle/gcr.io_00_linkerd-io_00_proxy-init:stable-2.1.0
tomoncle/gcr.io_00_linkerd-io_00_web:stable-2.1.0
tomoncle/gcr.io_00_linkerd-io_00_controller:stable-2.1.0
tomoncle/gcr.io_00_kubernetes-helm_00_tiller:v2.11.0
tomoncle/k8s.gcr.io_00_kubernetes-dashboard-amd64:v1.10.0
tomoncle/gcr.io_00_kubernetes-helm_00_tiller:v2.10.0
tomoncle/gcr.io_00_google_containers_00_defaultbackend:1.4
tomoncle/k8s.gcr.io_00_defaultbackend:1.4
"""

def search():
    command_docker = "docker images|grep tomoncle| awk '{printf(\"%s:%s\\n\",$1,$2)}'"
    (status, output) = commands.getstatusoutput(command_docker)
    if status != 0:
        print("command status : {}, search error! ".format(status))
        return
    images = output.split("\n")
    images = filter(lambda x: "_00_" in x, images)
    for image in images: print(image)


def download(r):
    download_command = "docker pull {}"
    if not isinstance(r, list):
        raise ValueError("r must be list type.")
    images = filter(lambda x: "_00_" in x, r)
    for image in images:
        try:
            (status, output) = commands.getstatusoutput(download_command.format(image))
            if status != 0:
                print("command status : {}, docker pull {} fail! ".format(status, image))
                continue
            print("{}\n\n".format(output))
            target = image.replace("tomoncle/", "").replace("_00_", "/")
            commands.getstatusoutput("docker tag {} {}".format(image, target))
            commands.getstatusoutput("docker rmi {}".format(image))
        except Exception as e:
            print("Error: download image {} error.".format(image), e)


if __name__ == "__main__":
    # search()
    print("\n\ndownloading...")
    data = image_data.split("\n")
    download(data)
