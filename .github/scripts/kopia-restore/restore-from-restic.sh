#!/bin/bash

# Restore from Restic-migrated Kopia snapshots
# Usage: ./restore-from-restic.sh <app_name> <namespace> [kopia_password]

set -e

APP_NAME="$1"
NAMESPACE="$2"
KOPIA_PASSWORD="$3"

if [ -z "$APP_NAME" ] || [ -z "$NAMESPACE" ]; then
    echo "Usage: $0 <app_name> <namespace> [kopia_password]"
    echo "Example: $0 radarr media-automation"
    exit 1
fi

CLAIM_NAME="${APP_NAME}-config"
KOPIA_PATH="${APP_NAME}@${NAMESPACE}:/data"

echo "=== Restore from Restic Migration ==="
echo "App: $APP_NAME"
echo "Namespace: $NAMESPACE"
echo "Claim: $CLAIM_NAME"
echo "Kopia Path: $KOPIA_PATH"

# Check if PVC exists
echo "Checking if PVC exists..."
if ! kubectl get pvc "$CLAIM_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Error: PVC '$CLAIM_NAME' not found in namespace '$NAMESPACE'"
    exit 1
fi

echo "✓ PVC '$CLAIM_NAME' found"

# Get Kopia password if not provided
if [ -z "$KOPIA_PASSWORD" ]; then
    read -s -p "Enter Kopia password: " KOPIA_PASSWORD
    echo
fi

# Connect to Kopia repository
echo "Connecting to Kopia repository..."
kopia repository connect filesystem --path=/mnt/tank/volsync-kopia --password="$KOPIA_PASSWORD"

# Find snapshot with "restic" in description
echo "Finding Restic-migrated snapshot..."
SNAPSHOT_ID=$(kopia snapshot list "$KOPIA_PATH" --json | jq -r '.[] | select(.description | contains("Restic")) | .id' | head -1)

if [ -z "$SNAPSHOT_ID" ] || [ "$SNAPSHOT_ID" = "null" ]; then
    echo "Error: No Restic-migrated snapshot found for $KOPIA_PATH"
    kopia repository disconnect
    exit 1
fi

echo "Found Restic snapshot: $SNAPSHOT_ID"

# Disconnect from Kopia
kopia repository disconnect

# Call the restore script
echo "Starting restore process..."
SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR/restore.sh" "$APP_NAME" "$NAMESPACE" "$SNAPSHOT_ID" "$KOPIA_PASSWORD"

echo "✓ Restore from Restic migration completed!"