#!/usr/bin/env bash
talosctl apply --insecure -n 10.0.1.10 --file clusterconfig/main-freya.rafaribe.com.yaml
sleep 30
talosctl apply --insecure -n 10.0.1.11 --file clusterconfig/main-loki.rafaribe.com.yaml
sleep 30
talosctl apply --insecure -n 10.0.1.12 --file clusterconfig/main-odin.rafaribe.com.yaml
sleep 30
talosctl apply --insecure -n 10.0.1.13 --file clusterconfig/main-thor.rafaribe.com.yaml
sleep 30
talosctl apply --insecure -n 10.0.1.13 --file clusterconfig/main-tyr.rafaribe.com.yaml
echo "sleeping"
sleep 120
echo "done sleeping"
talosctl -n 10.0.1.7 bootstrap

# # after provision

# talosctl apply -n 10.0.1.7 --file clusterconfig/skovald-odin.yaml
# talosctl apply -n 10.0.1.8 --file clusterconfig/skovald-loki.yaml

# talosctl apply -n 10.0.1.9 --file clusterconfig/skovald-thor.yaml
# talosctl apply -n 10.0.1.10 --file clusterconfig/skovald-freya.yaml
