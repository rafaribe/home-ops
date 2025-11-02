#!/bin/bash
# Script to comment out apps using Ceph storage in main kustomization

KUSTOMIZATION="/home/rafaribe/code/rafaribe/home-ops/kubernetes/apps/kustomization.yaml"

# Backup original
cp "$KUSTOMIZATION" "${KUSTOMIZATION}.backup"

# Comment out namespaces with Ceph PVCs
sed -i 's|^  - ./actions-runner-system|  # - ./actions-runner-system  # Uses ceph-block|' "$KUSTOMIZATION"
sed -i 's|^  - ./ai|  # - ./ai  # Uses ceph-block|' "$KUSTOMIZATION"
sed -i 's|^  - ./downloads|  # - ./downloads  # Uses ceph-block|' "$KUSTOMIZATION"
sed -i 's|^  - ./home|  # - ./home  # Uses ceph-block|' "$KUSTOMIZATION"
sed -i 's|^  - ./media|  # - ./media  # Uses ceph-block|' "$KUSTOMIZATION"
sed -i 's|^  - ./observability|  # - ./observability  # Uses ceph-block|' "$KUSTOMIZATION"

echo "Disabled Ceph-dependent apps. Backup saved to ${KUSTOMIZATION}.backup"
cat "$KUSTOMIZATION"
