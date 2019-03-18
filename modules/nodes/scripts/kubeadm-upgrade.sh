#!/usr/bin/env bash
set -o nounset -o errexit

sudo KUBECONFIG=/etc/kubernetes/kubelet.conf /opt/bin/kubectl drain $HOSTNAME --ignore-daemonsets
sudo KUBECONFIG=/etc/kubernetes/kubelet.conf /opt/bin/kubeadm upgrade node config --kubelet-version $(/opt/bin/kubelet --version | cut -d ' ' -f 2)
sudo systemctl restart kubelet
sudo KUBECONFIG=/etc/kubernetes/kubelet.conf /opt/bin/kubectl uncordon $HOSTNAME
