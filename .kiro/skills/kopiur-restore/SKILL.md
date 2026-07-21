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

## Workflow

### Step 1: Verify old data exists in the truenas repository

Spawn a helper pod to browse the Kopia repo:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: kopia-restore-helper
  namespace: kopiur-system
spec:
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

Connect and list snapshots:
```bash
kubectl exec -n kopiur-system kopia-restore-helper -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  repository connect filesystem --path=/repo \
  --override-hostname=kopiur --override-username=admin

kubectl exec -n kopiur-system kopia-restore-helper -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  snapshot list --all 2>&1 | grep "<app-name>"
```

**Identity convention in the truenas repo:**
- Hostname = namespace (e.g., `downloads`, `services`)
- Username = app name (e.g., `prowlarr`, `picoshare`)
- Path = `/data` (the VolSync source path)

### Step 2: Scale down the app

```bash
kubectl scale -n <namespace> deployment/<app> --replicas=0
kubectl wait --for=delete pod -l app.kubernetes.io/name=<app> -n <namespace> --timeout=60s
```

### Step 3: Create a restore pod

The restore pod mounts both the NFS Kopia repo and the app's PVC:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: <app>-restore
  namespace: <namespace>
spec:
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
```

Wait for it:
```bash
kubectl wait --for=condition=Ready pod/<app>-restore -n <namespace> --timeout=120s
```

### Step 4: Connect to the repository and restore

Connect with the correct identity (hostname=namespace, username=app):
```bash
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  repository connect filesystem --path=/repo \
  --override-hostname=<namespace> --override-username=<app>
```

List snapshots to find the latest one with real data:
```bash
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  snapshot list
```

Restore from the chosen snapshot:
```bash
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  restore <snapshot-id> /restore/ --overwrite-files --overwrite-directories
```

### Step 5: Clean up and scale back up

```bash
kubectl delete pod <app>-restore -n <namespace> --force
kubectl scale -n <namespace> deployment/<app> --replicas=1
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=<app> -n <namespace> --timeout=120s
```

### Step 6: Verify

```bash
# Pod is running
kubectl get pods -n <namespace> -l app.kubernetes.io/name=<app>

# Data is present (app-specific check)
kubectl exec -n <namespace> deploy/<app> -- ls /data/
```

## Batch Restore

When restoring multiple apps, you can reuse the helper pod in `kopiur-system` to browse snapshots, then create per-app restore pods in the correct namespace.

Recommended order:
1. Browse all snapshot sources with the helper pod
2. For each affected app: scale down → create restore pod → restore → clean up → scale up
3. Delete the helper pod when done

## Snapshot Identity Reference

| App | Hostname | Username | Path |
|-----|----------|----------|------|
| prowlarr | downloads | prowlarr | /data |
| picoshare | services | picoshare | /data |
| slink | services | slink | /data |
| lubelog | services | lubelog | /data |
| autobrr | downloads | autobrr | /data |
| metube | downloads | metube | /data |
| leafwiki | services | leafwiki | /data |
| reaplet | system-controllers | reaplet | /pvc/reaplet |

## Important Notes

- The `truenas` repository uses **uid 1000** file ownership — the restore pod must run as uid 1000
- Kopia needs writable paths for config/cache/logs — use `/tmp` via environment variables
- The NFS volume type triggers PodSecurity warnings but functions correctly
- Always verify data post-restore before considering the app recovered
- The kopiur `SnapshotSchedule` will start backing up the restored data to `garage-s3` automatically

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `permission denied` on `/repo/.shards` | Running as wrong UID (root gets squashed) | Run pod as `runAsUser: 1000` |
| `unable to create config directory` | Kopia image has non-writable `/app` | Set `HOME=/tmp` and use `--config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs` |
| `No snapshots found` | Connected with wrong hostname/username | Use `--override-hostname=<namespace> --override-username=<app>` |
| `Multi-Attach error` on PVC | Previous pod not fully terminated | Wait for old pod deletion, or force delete stuck restore pod |
| Snapshot ID not found | Using snapshot from different identity | List with `--all` to find correct identity, then reconnect |
