#!/usr/bin/env bash
set -o nounset -o errexit
export KUBECONFIG=$1
export HOSTNAME=$2

kubectl drain $HOSTNAME --ignore-daemonsets
