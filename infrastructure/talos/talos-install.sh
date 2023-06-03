#!/usr/bin/env bash

talosctl apply --insecure -n 10.0.1.12 --file clusterconfig/skovald-odin.yaml
talosctl apply --insecure -n 10.0.1.13 --file clusterconfig/skovald-loki.yaml
talosctl apply --insecure -n 10.0.1.14 --file clusterconfig/skovald-thor.yaml
talosctl apply --insecure -n 10.0.1.15 --file clusterconfig/skovald-freya.yaml
talosctl apply --insecure -n 10.0.1.16 --file clusterconfig/skovald-helya.yaml
sleep 60
talosctl -n 10.0.1.12 bootstrap
