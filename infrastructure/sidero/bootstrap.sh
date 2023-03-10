#!/usr/bin/env bash
# Script used to bootstrap
export SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=true
export SIDERO_CONTROLLER_MANAGER_API_ENDPOINT=10.0.1.6
export SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT=10.0.1.6
# Configure Cluster API to point to correct talos provider due to rename from talos-systems into sidero
mkdir -p ~/.cluster-api/
cp clusterctl.yaml ~/.cluster-api/clusterctl.yaml

## Bootstrap the sidero control panel

clusterctl init -b talos -c talos -i sidero
