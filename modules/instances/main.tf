data "linode_instance_type" "type" {
  id = "${var.node_type}"
}

resource "linode_instance" "instance" {
  count      = "${var.node_count}"
  region     = "${var.region}"
  label      = "${var.label_prefix == "" ? "" : "${var.label_prefix}-"}${var.node_class}-${count.index + 1}"
  group      = "${var.linode_group}"
  type       = "${var.node_type}"
  private_ip = "${var.private_ip}"

  disk {
    label           = "boot"
    size            = "${data.linode_instance_type.type.disk}"
    authorized_keys = ["${chomp(file(var.ssh_public_key))}"]
    image           = "linode/containerlinux"
  }

  config {
    label = "${var.node_class}"

    kernel = "linode/direct-disk"

    devices {
      sda = {
        disk_label = "boot"
      }
    }
  }

  provisioner "file" {
    source      = "${path.module}/scripts/"
    destination = "/tmp"

    connection {
      user    = "core"
      timeout = "300s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/start.sh && sudo /tmp/start.sh",
      "chmod +x /tmp/linode-network.sh && sudo /tmp/linode-network.sh ${self.private_ip_address} ${self.label}",
      "chmod +x /tmp/kubeadm-install.sh && sudo /tmp/kubeadm-install.sh ${var.k8s_version} ${var.cni_version} ${var.crictl_version} ${self.label} ${var.use_public ? self.ip_address : self.private_ip_address} ${var.k8s_feature_gates}",
    ]

    connection {
      user    = "core"
      timeout = "300s"
    }
  }
}

resource "null_resource" "upgrade" {
  count = "${var.node_count}"

  triggers {
    k8s_version       = "${var.k8s_version}"
    cni_version       = "${var.cni_version}"
    crictl_version    = "${var.crictl_version}"
    k8s_feature_gates = "${var.k8s_feature_gates}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/"
    destination = "/tmp"

    connection {
      host    = "${linode_instance.instance.*.ip_address[count.index]}"
      user    = "core"
      timeout = "300s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/kubeadm-upgrade.sh && sudo /tmp/kubeadm-upgrade.sh ${var.k8s_version} ${var.cni_version} ${var.crictl_version} ${var.k8s_feature_gates}",
    ]

    connection {
      host    = "${linode_instance.instance.*.ip_address[count.index]}"
      user    = "core"
      timeout = "300s"
    }
  }
}
