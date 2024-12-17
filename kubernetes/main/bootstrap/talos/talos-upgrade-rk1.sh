#!/usr/bin/env bash
echo "Special script to flash Turing RK1"

SCHEMATIC=factory.talos.dev/installer/c739f79cbeef721b97ddf8379a992a7d1a9a83104e349af4e358b351df51efb4
VERSION=v1.9.0

echo "Flashing $SCHEMATIC:VERSION of talos linux into the Turing Pi Rk1 Cluster"

# # talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.12 --image=$SCHEMATIC:$VERSION
# talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.13 --image=$SCHEMATIC:$VERSION
# talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.14 --image=$SCHEMATIC:$VERSION
# talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.15 --image=$SCHEMATIC:$VERSION
# # Optional
# talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.3 --image=factory.talos.dev/installer/f97465caafd11e9879c5d42e80db9e2e421b71d0437487aaa4b248a546344925:v1.9.0 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.4 --image=factory.talos.dev/installer/f97465caafd11e9879c5d42e80db9e2e421b71d0437487aaa4b248a546344925:v1.9.0 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.5 --image=factory.talos.dev/installer/ed9990c7b29702609bb02d1dd7fc7dff952b179559ba68808fd81a282044f49b:v1.9.0 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.8 --image=factory.talos.dev/installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.9.0 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.9 --image=factory.talos.dev/installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.9.0 --preserve;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.10 --image=factory.talos.dev/installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.9.0 --preserve;

echo "Finished Upgrading"
