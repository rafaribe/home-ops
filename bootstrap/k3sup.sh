#!/usr/bin/env bash
K3S_VERSION=v1.22.3+k3s1
k3sup install --ip="10.0.0.4" --user="rafaribe" --k3s-version="${K3S_VERSION}" --k3s-extra-args="--disable servicelb --disable traefik --disable metrics-server" --local-path=./kubeconfig

k3sup join \
    --ip=10.0.0.2 \
    --server-ip=10.0.0.4 \
    --server-user=rafaribe \
    --k3s-version="${K3S_VERSION}" \
    --user=rafaribe

cp ./kubeconfig ~/.kube/k3s
# k3sup join \
#     --ip=10.0.0.27 \
#     --server-ip=10.0.0.18 \
#     --server-user=rafaribe \
#     --k3s-version="${K3S_VERSION}" \
#     --user=rafaribe
