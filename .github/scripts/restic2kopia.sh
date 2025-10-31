#!/bin/bash

# Configuration with defaults
RESTIC_BASE_PATH="${RESTIC_BASE_PATH:-/mnt/storage-0}"
KOPIA_BASE_PATH="${KOPIA_BASE_PATH:-/mnt/tank/volsync-kopia}"
TEMP_RESTORE_PATH="${TEMP_RESTORE_PATH:-/tmp/restic-restore}"
FLUX_APPS_PATH="${FLUX_APPS_PATH:-/home/rafaribe/code/rafaribe/home-ops/kubernetes/apps}"

# Check required passwords
if [ -z "$RESTIC_PASSWORD" ]; then
    echo "Error: RESTIC_PASSWORD environment variable is required"
    exit 1
fi

if [ -z "$KOPIA_PASSWORD" ]; then
    echo "Error: KOPIA_PASSWORD environment variable is required"
    exit 1
fi

# Function to get namespace for an app
get_namespace() {
    local app_name="$1"
    
    # Search for the app folder in the flux repo structure
    local app_path=$(find "$FLUX_APPS_PATH" -type d -name "$app_name" 2>/dev/null | head -1)
    
    if [ -n "$app_path" ]; then
        # Get the parent directory name (namespace)
        local namespace=$(basename "$(dirname "$app_path")")
        echo "$namespace"
    else
        echo "default"
    fi
}

# Function to migrate a single app
migrate_app() {
    local app_name="$1"
    local restic_repo="$RESTIC_BASE_PATH/$app_name"
    local temp_path="$TEMP_RESTORE_PATH/$app_name"
    
    echo "=== Migrating $app_name ==="
    
    # Check if Restic repo exists
    if [ ! -d "$restic_repo" ]; then
        echo "Skipping $app_name - Restic repository not found"
        return
    fi
    
    # Get namespace for this app
    local namespace=$(get_namespace "$app_name")
    echo "Detected namespace: $namespace"
    
    # Get latest Restic snapshot
    export RESTIC_REPOSITORY="$restic_repo"
    export RESTIC_PASSWORD="$RESTIC_PASSWORD"
    
    local latest_snapshot=$(restic snapshots --json 2>/dev/null | jq -r '.[-1].id' 2>/dev/null)
    
    if [ "$latest_snapshot" = "null" ] || [ -z "$latest_snapshot" ]; then
        echo "Skipping $app_name - No snapshots found"
        return
    fi
    
    echo "Latest snapshot: $latest_snapshot"
    
    # Create temp directory and restore
    mkdir -p "$temp_path"
    echo "Restoring from Restic..."
    restic restore "$latest_snapshot" --target "$temp_path"
    
    if [ $? -ne 0 ]; then
        echo "Failed to restore $app_name"
        rm -rf "$temp_path"
        return
    fi
    
    # Connect to Kopia and create snapshot
    echo "Creating Kopia snapshot..."
    kopia repository connect filesystem --path="$KOPIA_BASE_PATH" --password="$KOPIA_PASSWORD" >/dev/null 2>&1
    
    kopia snapshot create "$temp_path" \
        --description="Restored from Restic - $app_name" \
        --override-source="$app_name@$namespace:/data"
    
    if [ $? -eq 0 ]; then
        echo "✓ Completed $app_name -> $app_name@$namespace:/data"
    else
        echo "✗ Failed to create Kopia snapshot for $app_name"
    fi
    
    kopia repository disconnect >/dev/null 2>&1
    
    # Cleanup
    rm -rf "$temp_path"
    echo
}

# Print configuration
echo "Configuration:"
echo "  Restic base path: $RESTIC_BASE_PATH"
echo "  Kopia base path: $KOPIA_BASE_PATH"
echo "  Temp restore path: $TEMP_RESTORE_PATH"
echo "  Flux apps path: $FLUX_APPS_PATH"
echo

# Get list of apps from Restic base directory
echo "Found Restic repositories:"
apps=()
for dir in "$RESTIC_BASE_PATH"/*; do
    if [ -d "$dir" ]; then
        app_name=$(basename "$dir")
        # Skip system directories
        if [[ "$app_name" != ".Trash-1000" && "$app_name" != "RESTORED" && "$app_name" != "immich-db-backups" && ! "$app_name" =~ ^\. ]]; then
            apps+=("$app_name")
            namespace=$(get_namespace "$app_name")
            echo "  - $app_name -> $namespace"
        fi
    fi
done

echo
echo "Total apps to migrate: ${#apps[@]}"
read -p "Proceed with migration? (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Migration cancelled"
    exit 0
fi

# Migrate all apps
for app_name in "${apps[@]}"; do
    migrate_app "$app_name"
done

echo "Migration completed!"
echo "Summary: Migrated ${#apps[@]} applications from Restic to Kopia"