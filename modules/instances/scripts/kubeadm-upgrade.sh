#!/usr/bin/env bash
set -o nounset -o errexit

K8S_VERSION=$1
CNI_VERSION=$2
CRICTL_VERSION=$3
K8S_FEATURE_GATES="$4"

cat << EOF > /etc/default/kubelet
KUBELET_EXTRA_ARGS="--cloud-provider=external --allow-privileged=true --feature-gates=${K8S_FEATURE_GATES}"
EOF

mkdir -p /etc/kubernetes/manifests /opt/cni/bin /opt/bin

curl -L 2>/dev/null "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

curl -L 2>/dev/null "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

cd /opt/bin
mv /opt/bin/kubelet{,.old}
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/{kubeadm,kubelet,kubectl} 2>/dev/null
chmod +x {kubeadm,kubelet,kubectl}
