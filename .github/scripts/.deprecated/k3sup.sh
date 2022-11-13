#!/usr/bin/env bash

K3S_VERSION=v1.25.3+k3s1
K3S_SERVER_IP="10.0.1.200"
K3S_USER="rafaribe"

k3sup join \
    --ip=10.0.1.14 \
    --server-ip=$K3S_SERVER_IP \
    --server-user=$K3S_USER \
    --k3s-version="${K3S_VERSION}" \
    --user=$K3S_USER --ssh-key=/home/rafaribe/.ssh/id_ed25519
