---
name: kopiur-restore
description: Restore an app's PVC data from the old VolSync Kopia repository (truenas NFS) after a kopiur migration left the PVC empty
---

# Kopiur Restore from VolSync Kopia Repository

This skill restores app data from the old VolSync Kopia repository (truenas NFS) into a PVC that was provisioned empty during migration to Kopiur.

## When to Use

After migrating an app from VolSync to `kopiur/backup`, the Restore CR may provision an empty PVC because:
- The Restore uses `source.fromPolicy` which looks for snapshots in the `garage-s3` repository
- The old data lives in the `truenas` repository (NFS-backed at `/mnt/tank/volsync-kopia`)
- The SnapshotPolicy had no prior snapshots in `garage-s3` at migration time
- `onMissingSnapshot: Continue` creates an empty volume instead of failing

### Distinguishing empty vs restored PVCs

A Restore CR with `phase: Completed` and `resolution: Snapshot` does **not** guarantee the data is correct.
The Restore might have pulled from an early post-migration snapshot (when Kopiur had already started backing up the empty PVC), restoring a skeleton config.

Always verify actual disk usage:
```bash
kubectl exec -n <namespace> deploy/<app> -- df -h /config
```

A healthy app has tens of MB. A skeleton config is typically < 10 MB.

## Prerequisites

- The `truenas` ClusterRepository must be `Ready`:
  ```bash
  kubectl get clusterrepository truenas -o jsonpath='{.status.phase}'
  ```
- The app must already be on `kopiur/backup` (PVC exists, managed by kopiur)
- The `kopiur-repository-secret` must exist in `kopiur-system` namespace (contains `KOPIA_PASSWORD`)

## Identifying Affected Apps

Check Restore CRs for `NoSnapshotContinue` status:
```bash
kubectl get restore -A -o json | jq -r '.items[] | select(.status.resolved.resolution == "NoSnapshot") | "\(.metadata.namespace)/\(.metadata.name)"'
```

Or check the Restore status message:
```bash
kubectl get restore -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,PHASE:.status.phase,MSG:.status.logTail'
```

Also cross-check disk usage for all apps in affected namespaces — a Restore showing `Completed` may have restored from an early empty snapshot:
```bash
for app in radarr sonarr prowlarr; do
  echo -n "$app: "; kubectl exec -n downloads deploy/$app -- df -h /config 2>/dev/null | tail -1
done
```

## Snapshot Identity Reference

The truenas Kopia repo contains two sets of identities per app, depending on when VolSync ran vs when Kopiur took over:

| Identity path | Meaning |
|---------------|---------|
| `<app>@<namespace>:/data` | Original VolSync source path — **the pre-migration data** |
| `<app>@<namespace>:/pvc/<app>` | Post-migration Kopiur path — may still be empty if migration was recent |

**Always target the `/data` identity** when restoring pre-migration data. The `/pvc/<app>` snapshots from the first few days after migration will be small (skeleton config) and should be skipped.

Use the snapshot list to identify the last good pre-migration snapshot: it will be the final entry under the `/data` identity, tagged `latest-1,daily-1,weekly-1,monthly-1,annual-1`, and have a size consistent with a healthy app (tens of MB, not single digits).

### Known app identities

| App | Hostname | Username | Pre-migration path | Post-migration path |
|-----|----------|---------|--------------------|---------------------|
| radarr | downloads | radarr | /data | /pvc/radarr |
| sonarr | downloads | sonarr | /data | /pvc/sonarr |
| prowlarr | downloads | prowlarr | /data | /pvc/prowlarr |
| autobrr | downloads | autobrr | /data | /pvc/autobrr |
| metube | downloads | metube | /data | /pvc/metube |
| picoshare | services | picoshare | /data | /pvc/picoshare |
| slink | services | slink | /data | /pvc/slink |
| lubelog | services | lubelog | /data | /pvc/lubelog |
| leafwiki | services | leafwiki | /data | /pvc/leafwiki |
| reaplet | system-controllers | reaplet | /pvc/reaplet | /pvc/reaplet |

## Workflow

### Step 0: Pin restore pods to a specific node (recommended: srv-08)

RWO (ReadWriteOnce) PVCs can only be attached to one node at a time. Pinning all restore pods to the same node (e.g. `srv-08`) avoids cross-node volume attachment conflicts and makes the stale-mount cleanup predictable.

Add `nodeName: srv-08` to every restore pod spec.

### Step 1: Find which node currently holds the PVC

Before creating the restore pod, check which node currently has the PVC attached:
```bash
PV=$(kubectl get pvc <pvc-name> -n <namespace> -o jsonpath='{.spec.volumeName}')
kubectl get volumeattachment -o json | \
  jq -r --arg pv "$PV" '.items[] | select(.spec.source.persistentVolumeName == $pv) | "node: \(.spec.nodeName) attached: \(.status.attached)"'
```

If the PVC is attached to a **different node** than where you want the restore pod (e.g. `tpi-3` but restore pod is on `srv-08`), you must detach it first — see the [RWO PVC detach procedure](#rwo-pvc-force-detach-procedure) below before creating the restore pod.

### Step 2: Verify old data exists in the truenas repository

Spawn a helper pod pinned to the same node as the restore pod:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: kopia-restore-helper
  namespace: kopiur-system
spec:
  nodeName: srv-08
  restartPolicy: Never
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: kopia
    image: kopia/kopia:0.19
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
    env:
    - name: KOPIA_PASSWORD
      valueFrom:
        secretKeyRef:
          name: kopiur-repository-secret
          key: KOPIA_PASSWORD
    volumeMounts:
    - name: repo
      mountPath: /repo
  volumes:
  - name: repo
    nfs:
      server: truenas.rafaribe.com
      path: /mnt/tank/volsync-kopia
EOF
```

Connect with the app's pre-migration identity and list snapshots:
```bash
kubectl exec -n kopiur-system kopia-restore-helper -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  repository connect filesystem --path=/repo \
  --override-hostname=<namespace> --override-username=<app>

kubectl exec -n kopiur-system kopia-restore-helper -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  snapshot list
```

Look for the final entry under `<app>@<namespace>:/data` — that is the last pre-migration snapshot. Note the snapshot ID (e.g. `kbca2aea85e6742e2a1a150a27ba3b10d`).

To browse all identities at once (useful for batch discovery):
```bash
kubectl exec -n kopiur-system kopia-restore-helper -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  snapshot list --all 2>&1 | grep "<app>"
```

### Step 3: Scale down the app

```bash
kubectl scale -n <namespace> deployment/<app> --replicas=0
kubectl wait --for=delete pod -l app.kubernetes.io/name=<app> -n <namespace> --timeout=60s
```

### Step 4: Handle RWO PVC node attachment

Scaling the deployment to zero does **not** immediately detach the Ceph RBD volume. The VolumeAttachment object persists and the kernel-level RBD map on the old node remains until kubelet cleans up.

If the PVC is still attached to a node different from where you're placing the restore pod:

#### RWO PVC force-detach procedure

```bash
# 1. Get the PV name
PV=$(kubectl get pvc <pvc-name> -n <namespace> -o jsonpath='{.spec.volumeName}')

# 2. Find and delete the VolumeAttachment
VA=$(kubectl get volumeattachment -o json | \
  jq -r --arg pv "$PV" '.items[] | select(.spec.source.persistentVolumeName == $pv) | .metadata.name')
kubectl delete volumeattachment "$VA"

# 3. Check if the RBD image is still mapped at the kernel level on the old node
# (deleting VolumeAttachment only frees the k8s object; kernel map may persist)
```

If the restore pod still fails with `rbd image ... is still being used`, the kernel RBD map and kubelet bind-mounts are stale on the old node. Force-clean them:

```bash
# Find which rbd device holds the volume on the old node
# The csi-rbdplugin container shares the host mount namespace
OLD_NODE_PLUGIN=$(kubectl get pods -n rook-ceph -o wide | grep "rook-ceph.rbd.csi.ceph.com-nodeplugin" | grep <old-node> | awk '{print $1}')

# Find the device number by matching the volume name in sysfs
for i in $(seq 0 40); do
  name=$(kubectl exec -n rook-ceph $OLD_NODE_PLUGIN -c csi-rbdplugin -- \
    cat /sys/bus/rbd/devices/$i/name 2>/dev/null) || continue
  echo "rbd$i: $name"
done
# Look for csi-vol-<uuid> matching your PV's volumeHandle

# Check what's still mounted
kubectl exec -n rook-ceph $OLD_NODE_PLUGIN -c csi-rbdplugin -- \
  cat /proc/mounts | grep rbd<N>

# Unmount pod bind-mount first, then global mount, then unmap
POD_MOUNT="/var/lib/kubelet/pods/<pod-uid>/volumes/kubernetes.io~csi/<pvc-name>/mount"
GLOBAL_MOUNT="/var/lib/kubelet/plugins/kubernetes.io/csi/rook-ceph.rbd.csi.ceph.com/<hash>/globalmount/<pool-id>"

kubectl exec -n rook-ceph $OLD_NODE_PLUGIN -c csi-rbdplugin -- umount "$POD_MOUNT"
kubectl exec -n rook-ceph $OLD_NODE_PLUGIN -c csi-rbdplugin -- umount "$GLOBAL_MOUNT"
kubectl exec -n rook-ceph $OLD_NODE_PLUGIN -c csi-rbdplugin -- rbd unmap /dev/rbd<N>
```

After this, the restore pod will attach successfully on the target node.

### Step 5: Create the restore pod

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: <app>-restore
  namespace: <namespace>
spec:
  nodeName: srv-08
  restartPolicy: Never
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: kopia
    image: kopia/kopia:0.19
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
    env:
    - name: KOPIA_PASSWORD
      valueFrom:
        secretKeyRef:
          name: kopiur-repository-secret
          key: KOPIA_PASSWORD
    volumeMounts:
    - name: repo
      mountPath: /repo
    - name: data
      mountPath: /restore
  volumes:
  - name: repo
    nfs:
      server: truenas.rafaribe.com
      path: /mnt/tank/volsync-kopia
  - name: data
    persistentVolumeClaim:
      claimName: <pvc-name>
EOF

kubectl wait --for=condition=Ready pod/<app>-restore -n <namespace> --timeout=120s
```

### Step 6: Connect to the repository and restore

Connect using the **pre-migration `/data` identity**:
```bash
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  repository connect filesystem --path=/repo \
  --override-hostname=<namespace> --override-username=<app>
```

Verify the current PVC contents before overwriting:
```bash
kubectl exec -n <namespace> <app>-restore -- ls -la /restore/
```

Restore from the last pre-migration snapshot:
```bash
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  restore <snapshot-id> /restore/ --overwrite-files --overwrite-directories
```

### Step 7: Clean up and scale back up

```bash
kubectl delete pod <app>-restore -n <namespace> --force
kubectl scale -n <namespace> deployment/<app> --replicas=1
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=<app> -n <namespace> --timeout=300s
```

Note: use `--timeout=300s` — the pod may need to pull the image if it was evicted from node cache.

### Step 8: Verify

```bash
# Pod is running and on expected node
kubectl get pods -n <namespace> -l app.kubernetes.io/name=<app> -o wide

# Data is present with correct size
kubectl exec -n <namespace> deploy/<app> -- df -h /config
kubectl exec -n <namespace> deploy/<app> -- ls -la /config/
```

A successful restore will show the `MediaCover`/`Backups` directories and a healthy-sized database, not just a `config.xml` and a small `.db` file.

## Batch Restore

When restoring multiple apps, reuse the helper pod in `kopiur-system` to browse all snapshots first, then work through apps one at a time.

Recommended order:
1. Spawn the helper pod on `srv-08`
2. For each affected app: check node attachment → scale down → force-detach if needed → create restore pod → restore → clean up → scale up
3. Delete the helper pod when done

Prefer restoring one app at a time to avoid juggling multiple stale RBD mounts simultaneously.

## Important Notes

- The `truenas` repository uses **uid 1000** file ownership — the restore pod must run as `runAsUser: 1000`
- Kopia needs writable paths for config/cache/logs — use `/tmp` via environment variables
- The NFS volume type triggers PodSecurity warnings (`restricted volume types`) but functions correctly
- Scaling a deployment to zero does **not** immediately release a Ceph RBD volume from the node — the VolumeAttachment object and kernel RBD map persist until kubelet cleans up or you force-clean them
- The kopiur `SnapshotSchedule` will automatically start backing up the restored data to `garage-s3` after the app starts

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `permission denied` on `/repo/.shards` | Running as wrong UID (root gets squashed by NFS) | Run pod as `runAsUser: 1000` |
| `unable to create config directory` | Kopia image has non-writable `/app` | Set `HOME=/tmp` and use `--config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs` |
| `No snapshots found` | Connected with wrong hostname/username | Use `--override-hostname=<namespace> --override-username=<app>` |
| `Multi-Attach error` on PVC | VolumeAttachment not yet deleted, or stale kernel RBD map | Delete VolumeAttachment object, then force-unmap via csi-rbdplugin if still stuck |
| `rbd image ... is still being used` | Kernel RBD map and kubelet bind-mounts still live on old node after VA deletion | Find device via sysfs on old node's csi-rbdplugin, umount both paths, then `rbd unmap` |
| `Snapshot ID not found` | Using snapshot from wrong identity (`/pvc/<app>` instead of `/data`) | Reconnect with `--override-hostname` matching the pre-migration identity and list again |
| Restore CR shows `Completed` but PVC is empty | Kopiur restored from an early post-migration snapshot (empty PVC backup) | Ignore the Restore CR; follow this manual procedure using the `/data` identity |
| App pod goes to `ContainerCreating` for long time after restore | Image pull on the target node after a node switch | Normal — wait up to 5 minutes; use `--timeout=300s` on the wait command |
