#!/usr/bin/env bash
echo "Special script to flash Turing RK1"

talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.12 --image=factory.talos.dev/metal-installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.13 --image=factory.talos.dev/metal-installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.14 --image=factory.talos.dev/metal-installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.15 --image=factory.talos.dev/metal-installer/0c1cf9349bef184f071d638fb78267375915f18a45c1543e9e5684bf9a22044f:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.3 --image=factory.talos.dev/metal-installer/47c2728442d81a73bf48c821ba1e1fa93e9a65c6ca27b82a74585122fe65899a:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.4 --image=factory.talos.dev/metal-installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.5 --image=factory.talos.dev/metal-installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.8 --image=factory.talos.dev/metal-installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.9 --image=factory.talos.dev/metal-installer/47c2728442d81a73bf48c821ba1e1fa93e9a65c6ca27b82a74585122fe65899a:v1.10.3;
talosctl upgrade --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.10 --image=factory.talos.dev/metal-installer/47c2728442d81a73bf48c821ba1e1fa93e9a65c6ca27b82a74585122fe65899a:v1.10.3;
