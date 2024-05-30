#!/usr/bin/env bash
talosctl apply -n 10.0.0.4 --file clusterconfig/main-thor.home.arpa.yaml
sleep 30
talosctl apply -n 10.0.0.5 --file clusterconfig/main-loki.home.arpa.yaml
sleep 30
talosctl apply -n 10.0.0.8 --file clusterconfig/main-freya.home.arpa.yaml
sleep 30
talosctl apply -n 10.0.0.3 --file clusterconfig/main-odin.home.arpa.yaml
sleep 30
talosctl apply -n 10.0.0.7 --file clusterconfig/main-tyr.home.arpa.yaml
echo "sleeping"
sleep 120
echo "done sleeping"
talosctl -n 10.0.0.4 bootstrap

# # after provision

# talosctl apply -n 10.0.1.7 --file clusterconfig/skovald-odin.yaml
# talosctl apply -n 10.0.1.8 --file clusterconfig/skovald-loki.yaml

# talosctl apply -n 10.0.1.9 --file clusterconfig/skovald-thor.yaml
# talosctl apply -n 10.0.1.10 --file clusterconfig/skovald-freya.yaml
