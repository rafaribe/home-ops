#!/usr/bin/env bash
echo "Special script to flash Turing RK1 with Nico Berlee's Fork of Talos"

FORK=ghcr.io/nberlee/installer
VERSION=v1.8.3-rk3588

echo "Flashing $FORK:VERSION of talos linux into the Turing Pi Rk1 Cluster"

talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.12 --image=$FORK:$VERSION --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.13 --image=$FORK:$VERSION --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.14 --image=$FORK:$VERSION --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.15 --image=$FORK:$VERSION --preserve;

echo "Finished Upgrading