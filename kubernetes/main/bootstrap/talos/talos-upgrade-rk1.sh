#!/usr/bin/env bash
echo "Special script to flash Turing RK1 with Nico Berlee's Fork of Talos"

FORK=ghcr.io/nberlee/installer
VERSION=v1.8.3-rk3588

echo "Flashing $FORK:VERSION of talos linux into the Turing Pi Rk1 Cluster"

talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.12 --image=$FORK:$VERSION
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.13 --image=$FORK:$VERSION
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.14 --image=$FORK:$VERSION
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.15 --image=$FORK:$VERSION
# Optional
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.3 --image=factory.talos.dev/installer/afc233feba1c97e7f0174831b3d1d74e604fb696302385373f4a5bd0644d6a78:v1.8.3 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.4 --image=factory.talos.dev/installer/afc233feba1c97e7f0174831b3d1d74e604fb696302385373f4a5bd0644d6a78:v1.8.3 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.5 --image=factory.talos.dev/installer/9ab2857e510445ccf37df0b62dc4ceb9f88a3083a6a29dcfcb2b426728a11ec0:v1.8.3 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.8 --image=factory.talos.dev/installer/0f3c8b57b87e397d464074093ac5a7eaa60151c6a71e201cb34c7a3a9562cd6b:v1.8.3 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.9 --image=factory.talos.dev/installer/0f3c8b57b87e397d464074093ac5a7eaa60151c6a71e201cb34c7a3a9562cd6b:v1.8.3 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.10 --image=factory.talos.dev/installer/0f3c8b57b87e397d464074093ac5a7eaa60151c6a71e201cb34c7a3a9562cd6b:v1.8.3 --preserve;

echo "Finished Upgrading"
