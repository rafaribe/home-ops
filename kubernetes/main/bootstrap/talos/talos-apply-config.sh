#!/usr/bin/env bash
echo "Special script to apply apply config"


talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.4 --file=./clusterconfig/main-srv-03.home.arpa.yaml;
sleep 180
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.5 --file=./clusterconfig/main-srv-04.home.arpa.yaml;
sleep 180
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.8 --file=./clusterconfig/main-srv-05.home.arpa.yaml;
sleep 180
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.9 --file=./clusterconfig/main-srv-06.home.arpa.yaml;
sleep 180
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.10 --file=./clusterconfig/main-srv-07.home.arpa.yaml;

echo "applied config"
