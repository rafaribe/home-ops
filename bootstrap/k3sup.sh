#!/usr/bin/env bash

k3sup install --ip="10.0.0.2" --user="pi" --k3s-version="v1.21.4+k3s1" --k3s-extra-args="--disable servicelb --disable traefik --disable metrics-server"

k3sup join \
    --ip=10.0.0.18 \
    --server-ip=10.0.0.2 \
    --server-user=pi \
    --k3s-version=v1.21.4+k3s1 \
    --user=brr

k3sup join \
    --ip=10.0.0.27 \
    --server-ip=10.0.0.2 \
    --server-user=pi \
    --k3s-version=v1.21.4+k3s1 \
    --user=pi
