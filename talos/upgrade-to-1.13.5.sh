#!/usr/bin/env bash
set -euo pipefail

TALOSCONFIG="./clusterconfig/talosconfig"
ENDPOINT="10.0.1.7"  # srv-07 (CP already on v1.13.5)
IMAGE_WORKER="factory.talos.dev/metal-installer/fa1c50ea4f64a6b40af4a7d75e3054c040de7f69baba9177dc4960bee0a94bec:v1.13.5"
IMAGE_CP="factory.talos.dev/metal-installer/a62ab98a1207142df0461cf97d831d719be6e7be8eae37d3accb3d65190bc93a:v1.13.5"
IMAGE_SRV08="factory.talos.dev/metal-installer/3ebae0b3a212f0633f43da43981fed6d3d9757c0415b6e8081d3074bf735c428:v1.13.5"
IMAGE_TPI1="factory.talos.dev/metal-installer/b7476e99b65e487fced87bb2b150a80cfff8b5f46b481c4d6dd46c5b0c24110e:v1.13.5"

upgrade() {
  local node=$1 image=$2
  echo ">>> Upgrading $node"
  talosctl upgrade --talosconfig="$TALOSCONFIG" --nodes="$node" --endpoints="$ENDPOINT" \
    --image="$image"
  echo ">>> Waiting for $node to come back..."
  sleep 30
  until talosctl version --talosconfig="$TALOSCONFIG" --nodes="$node" --endpoints="$ENDPOINT" 2>/dev/null | grep -q "v1.13.5"; do
    sleep 10
  done
  echo ">>> $node upgraded to v1.13.5"
}

# 1. Workers first
echo "=== PHASE 1: Workers ==="
upgrade 10.0.1.4 "$IMAGE_WORKER"   # srv-04
upgrade 10.0.1.5 "$IMAGE_WORKER"   # srv-05
upgrade 10.0.1.6 "$IMAGE_WORKER"   # srv-06
upgrade 10.0.1.12 "$IMAGE_SRV08"   # srv-08
upgrade 10.0.1.8 "$IMAGE_TPI1"     # tpi-1

# 2. Control plane nodes one at a time (maintain etcd quorum)
echo "=== PHASE 2: Control Plane (one at a time) ==="
upgrade 10.0.1.2 "$IMAGE_CP"       # srv-02
upgrade 10.0.1.3 "$IMAGE_CP"       # srv-03
# srv-07 already on v1.13.5

echo "=== All nodes upgraded ==="
