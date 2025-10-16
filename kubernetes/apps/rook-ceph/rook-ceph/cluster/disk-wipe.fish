#!/usr/bin/env fish

set -x TALOSCONFIG /Users/rafaribe/code/rafaribe/home-ops/kubernetes/bootstrap/talos/clusterconfig/talosconfig

# Define disk operations
set operations \
    "sdb 10.0.1.1" \
    "sda 10.0.1.2" \
    "sda 10.0.1.3" \
    "sda 10.0.1.4" \
    "sdd 10.0.1.4" \
    "sda 10.0.1.5" \
    "sdb 10.0.1.6" \
    "sdb 10.0.1.7" \
    "nvme0n1 10.0.1.8" \
    "nvme0n1 10.0.1.9" \
    "nvme0n1 10.0.1.10" \
    "nvme0n1 10.0.1.11"

echo "🚨 WARNING: This will PERMANENTLY WIPE the following disks:"
for op in $operations
    set disk (echo $op | cut -d' ' -f1)
    set node (echo $op | cut -d' ' -f2)
    echo "  - Disk $disk on node $node"
end

echo ""
read -P "Are you sure you want to continue? [y/N]: " confirm

if test "$confirm" != "y" -a "$confirm" != "Y"
    echo "❌ Operation cancelled"
    exit 1
end

echo "🔄 Starting disk wipe operations..."

for op in $operations
    set disk (echo $op | cut -d' ' -f1)
    set node (echo $op | cut -d' ' -f2)
    
    echo "🗑️  Wiping disk $disk on node $node..."
    if talosctl wipe disk $disk -n $node
        echo "✅ Successfully wiped $disk on $node"
    else
        echo "❌ Failed to wipe $disk on $node"
    end
end

echo "🎉 Disk wipe operations completed"

