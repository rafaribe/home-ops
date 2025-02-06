#!/usr/bin/env bash
echo "Special script to flash Turing RK1"

talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.12 --image=factory.talos.dev/installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.13 --image=factory.talos.dev/installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.14 --image=factory.talos.dev/installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.15 --image=factory.talos.dev/installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.3 --image=factory.talos.dev/installer/f97465caafd11e9879c5d42e80db9e2e421b71d0437487aaa4b248a546344925:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.4 --image=factory.talos.dev/installer/f97465caafd11e9879c5d42e80db9e2e421b71d0437487aaa4b248a546344925:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.5 --image=factory.talos.dev/installer/f97465caafd11e9879c5d42e80db9e2e421b71d0437487aaa4b248a546344925:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.8 --image=factory.talos.dev/installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.9 --image=factory.talos.dev/installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.9.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.10 --image=factory.talos.dev/installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.9.3;