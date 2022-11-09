#!/usr/bin/env bash

K3S_VERSION=v1.25.2+k3s1
K3S_SERVER_IP="10.0.1.200"
K3S_USER="rafaribe"
k3sup install --ip=$K3S_SERVER_IP --user=$K3S_USER --k3s-version="${K3S_VERSION}" --k3s-extra-args="--disable servicelb --disable traefik --disable local-storage --flannel-backend=none --disable-network-policy" --local-path=./kubeconfig --ssh-key=/home/rafaribe/.ssh/id_ed25519

k3sup join \
    --ip=10.0.1.201 \
    --server-ip=$K3S_SERVER_IP \
    --server-user=$K3S_USER \
    --k3s-version="${K3S_VERSION}" \
    --user=$K3S_USER --ssh-key=/home/rafaribe/.ssh/id_ed25519

k3sup join \
    --ip=10.0.1.202 \
    --server-ip=$K3S_SERVER_IP \
    --server-user=$K3S_USER \
    --k3s-version="${K3S_VERSION}" \
    --user=$K3S_USER --ssh-key=/home/rafaribe/.ssh/id_ed25519
cp ./kubeconfig ~/.kube/home-ops
cd ~/.kube && ./update-kubeconfig.sh
kubectx home-ops

helm install cilium cilium/cilium --values values.yaml
