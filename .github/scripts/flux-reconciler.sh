#!/bin/bash

# Function to reconcile a Kustomization
reconcile_kustomization() {
  local namespace="$1"
  local name="$2"
  echo "Reconciling Kustomization: $namespace/$name"
  flux reconcile kustomization --namespace="$namespace" "$name"
}

# Get a list of all Kustomizations
kustomizations=$(flux get kustomizations --all-namespaces | awk 'NR>1')

if [[ -n "$kustomizations" ]]; then
  # Iterate through the Kustomizations
  while read -r kustomization; do
    namespace=$(echo "$kustomization" | awk '{print $1}')
    name=$(echo "$kustomization" | awk '{print $2}')

    # Check if the Kustomization is not ready and reconcile it
    if ! flux get kustomization --namespace="$namespace" "$name" | grep -q 'Ready'; then
      reconcile_kustomization "$namespace" "$name"
    fi
  done <<< "$kustomizations"
else
  echo "No Kustomizations found."
fi
