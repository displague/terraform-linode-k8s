#!/usr/bin/env bash
set -o nounset -o errexit

K8S_VERSION=$1
CNI_VERSION=$2
CRICTL_VERSION=$3
K8S_FEATURE_GATES="$4"

sudo /opt/bin/kubeadm upgrade apply ${K8S_VERSION}
sudo systemctl restart kubelet
