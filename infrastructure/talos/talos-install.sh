#!/usr/bin/env bash

#talosctl apply --insecure -n 10.0.1.7 --file clusterconfig/skovald-odin.yaml
talosctl apply --insecure -n 10.0.1.8 --file clusterconfig/skovald-loki.yaml
talosctl apply --insecure -n 10.0.1.9 --file clusterconfig/skovald-thor.yaml
talosctl apply --insecure -n 10.0.1.10 --file clusterconfig/skovald-freya.yaml
echo "sleeping"
sleep 60
echo "done sleeping"
talosctl -n 10.0.1.7 bootstrap

# # after provision

# talosctl apply -n 10.0.1.7 --file clusterconfig/skovald-odin.yaml
# talosctl apply -n 10.0.1.8 --file clusterconfig/skovald-loki.yaml

# talosctl apply -n 10.0.1.9 --file clusterconfig/skovald-thor.yaml
# talosctl apply -n 10.0.1.10 --file clusterconfig/skovald-freya.yaml
