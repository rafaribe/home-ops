#!/usr/bin/env bash

echo "Applying configuration to Node 10.0.0.4 thor.cluster.home"
talosctl apply -n 10.0.0.4 --file clusterconfig/main-thor.home.arpa.yaml --mode=auto
sleep 2

echo "Applying configuration to Node 10.0.0.5 loki.cluster.home"
talosctl apply -n 10.0.0.5 --file clusterconfig/main-loki.home.arpa.yaml --mode=auto
sleep 2

echo "Applying configuration to Node 10.0.0.8 freya.cluster.home"
talosctl apply -n 10.0.0.8 --file clusterconfig/main-freya.home.arpa.yaml --mode=auto
sleep 2

echo "Applying configuration to Node 10.0.0.3 odin.cluster.home"
talosctl apply -n 10.0.0.3 --file clusterconfig/main-odin.home.arpa.yaml --mode=auto
sleep 2

echo "Applying configuration to Node 10.0.0.7 tyr.cluster.home"
talosctl apply -n 10.0.0.7 --file clusterconfig/main-tyr.home.arpa.yaml --mode=auto
sleep 2

echo "Applying configuration to Node 10.0.0.9 mimir.cluster.home"
talosctl apply -n 10.0.0.12 --file clusterconfig/main-mimir.home.arpa.yaml --mode=auto
sleep 2

echo "Applying configuration to Node 10.0.0.11 heimdall.cluster.home"
talosctl apply-config --insecure -n 10.0.0.11 --file clusterconfig/main-heimdall.home.arpa.yaml
#talosctl apply -n 10.0.0.11 --file clusterconfig/main-heimdall.home.arpa.yaml --mode=auto
sleep 2

echo "Bootstrapping the cluster"
