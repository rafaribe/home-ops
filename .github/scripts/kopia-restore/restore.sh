#!/bin/bash

# Kopia Restore Script
# Usage: ./restore.sh <app_name> <namespace> [snapshot_id] [kopia_password]

set -e

APP_NAME="$1"
NAMESPACE="$2"
SNAPSHOT_ID="$3"
KOPIA_PASSWORD="$4"

if [ -z "$APP_NAME" ] || [ -z "$NAMESPACE" ]; then
    echo "Usage: $0 <app_name> <namespace> [snapshot_id] [kopia_password]"
    echo "Example: $0 radarr media-automation"
    echo "Example: $0 radarr media-automation k1234567890abcdef"
    echo "Example: $0 radarr media-automation k1234567890abcdef mypassword"
    exit 1
fi

CLAIM_NAME="${APP_NAME}"
DEPLOYMENT_NAME="$APP_NAME"
KOPIA_PATH="/data/${NAMESPACE}/${APP_NAME}/${CLAIM_NAME}"

echo "=== Kopia Restore Process ==="
echo "App: $APP_NAME"
echo "Namespace: $NAMESPACE"
echo "Claim: $CLAIM_NAME"
echo "Kopia Path: $KOPIA_PATH"

# Get snapshot ID if not provided
if [ -z "$SNAPSHOT_ID" ]; then
    echo "Getting latest snapshot ID..."
    SNAPSHOT_ID=$(kopia snapshot list "$KOPIA_PATH" --json | jq --raw-output '.[-1] | .id')
    if [ -z "$SNAPSHOT_ID" ] || [ "$SNAPSHOT_ID" = "null" ]; then
        echo "Error: No snapshots found for $KOPIA_PATH"
        exit 1
    fi
fi

# Get Kopia password if not provided
if [ -z "$KOPIA_PASSWORD" ]; then
    read -s -p "Enter Kopia password: " KOPIA_PASSWORD
    echo
fi

echo "Snapshot ID: $SNAPSHOT_ID"
echo

# Step 1: Scale down deployment
echo "Step 1: Scaling down deployment..."
kubectl scale --replicas=0 deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"

# Step 2: Wait for pod deletion
echo "Step 2: Waiting for pod deletion..."
kubectl -n "$NAMESPACE" wait pod --for delete --selector="app.kubernetes.io/name=$APP_NAME" --timeout=2m || true

# Step 3: Create and apply restore job using envsubst
echo "Step 3: Creating restore job..."
export APP="$APP_NAME"
export NAMESPACE="$NAMESPACE"
export CLAIM="$CLAIM_NAME"
export SNAPSHOT="$SNAPSHOT_ID"
export KOPIA_PASSWORD="$KOPIA_PASSWORD"

envsubst < "$(dirname "$0")/restore-job.yaml" | kubectl apply -f -

# Step 4: Wait for job completion and show logs
echo "Step 4: Waiting for restore job completion..."
RESTORE_JOB_NAME="${APP_NAME}-${CLAIM_NAME}-restore"
kubectl -n "$NAMESPACE" wait --for=condition=complete job/"$RESTORE_JOB_NAME" --timeout=10m

echo "Step 5: Showing restore logs..."
kubectl -n "$NAMESPACE" logs job/"$RESTORE_JOB_NAME"

# Step 6: Clean up restore job
echo "Step 6: Cleaning up restore job..."
kubectl -n "$NAMESPACE" delete job "$RESTORE_JOB_NAME"

# Step 7: Scale back up deployment
echo "Step 7: Scaling back up deployment..."
kubectl scale --replicas=1 deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"

echo
echo "✓ Restore completed successfully!"
echo "App: $APP_NAME"
echo "Namespace: $NAMESPACE"
echo "Snapshot: $SNAPSHOT_ID"