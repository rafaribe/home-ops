#!/usr/bin/env bash

K3S_VERSION=v1.27.2+k3s1
K3S_SERVER_IP="10.0.1.13"
K3S_USER="brr"

k3sup install \
    --user=$K3S_USER \
    --ip=$K3S_SERVER_IP \
    --k3s-version="${K3S_VERSION}" \
    --user=$K3S_USER --ssh-key=$HOME/.ssh/id_ed25519 \
    --context homeops \
    --k3s-extra-args '--disable traefik --flannel-backend=none --disable-network-policy --disable=servicelb'

# k3sup join \
#     --ip=10.0.1.13 \
#     --server-ip=$K3S_SERVER_IP \
#     --server-user=$K3S_USER \
#     --k3s-version="${K3S_VERSION}" \
#     --user $K3S_USER \
#     --user=$K3S_USER --ssh-key=$HOME/.ssh/id_ed25519

k3sup join \
    --ip=10.0.1.14 \
    --server-ip=$K3S_SERVER_IP \
    --server-user=$K3S_USER \
    --k3s-version="${K3S_VERSION}" \
    --user $K3S_USER \
    --user=$K3S_USER --ssh-key=$HOME/.ssh/id_ed25519
k3sup join \
    --ip=10.0.1.15 \
    --server-ip=$K3S_SERVER_IP \
    --server-user=$K3S_USER \
    --k3s-version="${K3S_VERSION}" \
    --user $K3S_USER \
    --user=$K3S_USER --ssh-key=$HOME/.ssh/id_ed25519
