---
name: migrate-volsync-to-kopiur
description: Migrate an app's PVC backup from VolSync to Kopiur with zero data loss
---

# Migrate VolSync to Kopiur

This skill migrates an app's PVC backup from VolSync (kopia mover) to Kopiur. The existing NFS-based kopia repository is adopted in place — all snapshots are preserved with zero data loss.

## Architecture

Kopiur's `truenas` ClusterRepository points to the same NFS Kopia repo that VolSync used (`/mnt/tank/volsync-kopia`). Key settings that enable seamless adoption:

- `identityDefaults.hostnameExpr: namespace` — matches VolSync's hostname pattern
- `identityDefaults.usernameExpr: policyName` — matches VolSync's username (app name)
- `credentialProjection.allowed: true` — allows per-namespace credential access
- `allow-identity-change: "true"` annotation on SnapshotPolicy — lets kopiur adopt snapshots under the existing identity

Because kopiur writes to the **same repository** with the **same identity**, the Restore CR can find existing VolSync snapshots directly.

## Prerequisites

Before migrating any app, verify:

```bash
# Kopiur operator healthy
kubectl get helmrelease -n kopiur-system kopiur

# truenas ClusterRepository ready
kubectl get clusterrepository truenas -o jsonpath='{.status.phase}'
# Should output: Ready

# Verify snapshot count shows existing VolSync data
kubectl get clusterrepository truenas -o jsonpath='{.status.storageStats.snapshotCount}'
```

The target namespace must include the `kopiur/secret` component in its `kustomization.yaml`:
```yaml
components:
  - ../../components/kopiur/secret
```

Namespaces already configured: `services`, `system-controllers`, `downloads`.
Check before migration:
```bash
kubectl get secret kopiur-repository-secret -n <namespace>
```

## Migration Strategy (from joryirving's pattern)

### Key Principles

1. **Same repository** — Kopiur writes to the same NFS Kopia repo VolSync used
2. **Same identity** — `hostname=namespace`, `username=appname` matches VolSync's pattern
3. **Identity adoption** — `allow-identity-change` annotation lets kopiur take over existing snapshots
4. **Credential projection** — per-namespace secrets allow Restore/Snapshot pods to authenticate
5. **Fail-safe restore** — backup component uses `onMissingSnapshot: Continue` (app starts if no snapshot); the separate `restore` component uses `onMissingSnapshot: Fail` for explicit recovery

### Components Available

| Component | Purpose |
|-----------|---------|
| `kopiur/backup` | Full migration: PVC + Restore + SnapshotPolicy + SnapshotSchedule |
| `kopiur/backup-nopvc` | Same as backup but without PVC creation (app manages its own PVC) |
| `kopiur/snapshot-only` | Parallel phase: SnapshotPolicy + SnapshotSchedule only (keeps VolSync PVC) |
| `kopiur/restore` | One-shot recovery: creates a separate PVC from old identity snapshots |

## Workflow

### Step 1: Verify existing snapshots exist in truenas repo

```bash
# Spawn a helper pod (see kopiur-restore skill for full pod spec)
kubectl exec -n kopiur-system kopia-restore-helper -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  snapshot list --all 2>&1 | grep "<app>@<namespace>"
```

Verify the snapshot has real data (non-zero size, files > 0).

### Step 2: Edit the app's `ks.yaml`

Replace the volsync component with kopiur/backup:

```yaml
# Before
spec:
  dependsOn:
    - name: volsync
      namespace: storage
  components:
    - ../../../../components/volsync
  postBuild:
    substitute:
      APP: *app
      VOLSYNC_CAPACITY: 5Gi

# After
spec:
  dependsOn:
    - name: kopiur
      namespace: kopiur-system
    - name: rook-ceph-cluster
      namespace: rook-ceph
  components:
    - ../../../../components/kopiur/backup
  postBuild:
    substitute:
      APP: *app
      KOPIUR_CAPACITY: 5Gi
```

Variable mapping:
| VolSync | Kopiur | Default |
|---------|--------|---------|
| `VOLSYNC_CAPACITY` | `KOPIUR_CAPACITY` | `5Gi` |
| `VOLSYNC_ACCESSMODES` | `KOPIUR_ACCESSMODES` | `ReadWriteOnce` |
| `VOLSYNC_STORAGECLASS` | `KOPIUR_STORAGECLASS` | `ceph-block` |
| `VOLSYNC_CACHE_CAPACITY` | (not needed) | — |
| `CLAIM` | (not needed, always `${APP}`) | — |

Remove any extra volsync vars (`VOLSYNC_CACHE_CAPACITY`, `CLAIM`).

Optional overrides (only if non-default):
- `KOPIUR_SNAPSHOTCLASS`: `csi-ceph-blockpool` (default)
- `KOPIUR_PUID`: `1000` (default)
- `KOPIUR_PGID`: `1000` (default)

### Step 3: Update the helmrelease persistence (if needed)

If the helmrelease uses `existingClaim: ${CLAIM:=${APP}}` or similar, simplify to:
```yaml
persistence:
  data:
    existingClaim: ${APP}
```

The kopiur backup component creates the PVC named `${APP}` automatically.

### Step 4: Delete the old PVC

The kopiur backup component creates a PVC with `dataSourceRef` pointing to the `Restore` CR. The old VolSync PVC must be deleted:

```bash
kubectl -n <namespace> delete pvc <app>
```

If the PVC is stuck in `Terminating`:
```bash
kubectl -n <namespace> patch pvc <app> -p '{"metadata":{"finalizers":null}}' --type=merge
```

The Restore CR finds existing snapshots via the SnapshotPolicy (same identity as VolSync used) and populates the new PVC.

### Step 5: Commit, push, reconcile

```bash
git add kubernetes/apps/<namespace>/<app>/
git commit -m "feat(<app>): migrate backup from volsync to kopiur"
git push
flux reconcile source git flux-system
flux reconcile ks <app> -n flux-system
```

### Step 6: Verify

```bash
# Restore found snapshot (not NoSnapshot)
kubectl get restore -n <namespace> <app> -o jsonpath='{.status.resolved.resolution}'
# Should be: Snapshot (not NoSnapshot)

# PVC bound
kubectl get pvc -n <namespace> <app>

# Pod running
kubectl get pods -n <namespace> -l app.kubernetes.io/name=<app>

# Data present (app-specific)
kubectl exec -n <namespace> deploy/<app> -- ls /data/

# First kopiur snapshot succeeds
kubectl get snapshot -n <namespace> -l kopiur.home-operations.com/schedule=<app> --sort-by=.metadata.creationTimestamp | tail -3
```

### Step 7: Fallback — Manual Restore if Resolution is NoSnapshot

The Restore CR may resolve `NoSnapshot` even though data exists in the truenas repo. This happens when:
- The `snapshot-only` phase wrote snapshots to `garage-s3` (old config) not `truenas`
- The SnapshotPolicy identity hasn't been adopted yet (first snapshot hasn't fired under new identity)
- The old VolSync snapshots used a slightly different identity format

**If the Restore resolves `NoSnapshot` and the app starts with empty data, perform a manual restore:**

```bash
# 1. Scale down the app
kubectl scale -n <namespace> deployment/<app> --replicas=0
kubectl wait --for=delete pod -l app.kubernetes.io/name=<app> -n <namespace> --timeout=60s

# 2. Create a restore pod
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
      claimName: <app>
EOF

# 3. Wait for pod, connect to repo with the correct identity
kubectl wait --for=condition=Ready pod/<app>-restore -n <namespace> --timeout=120s

kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  repository connect filesystem --path=/repo \
  --override-hostname=<namespace> --override-username=<app>

# 4. List snapshots and pick the latest with real data
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  snapshot list

# 5. Restore from the chosen snapshot
kubectl exec -n <namespace> <app>-restore -- env \
  KOPIA_CACHE_DIRECTORY=/tmp/kopia-cache HOME=/tmp \
  kopia --config-file=/tmp/kopia.config --log-dir=/tmp/kopia-logs \
  restore <snapshot-id> /restore/ --overwrite-files --overwrite-directories

# 6. Clean up and scale back up
kubectl delete pod <app>-restore -n <namespace> --force
kubectl scale -n <namespace> deployment/<app> --replicas=1
```

**After manual restore:** The next hourly SnapshotSchedule will take a snapshot of the restored data under the correct kopiur identity. Future Restores will find it automatically. This manual step is only needed once per app during the migration window.

**Also clean up stale VolSync resources:**
```bash
kubectl -n <namespace> delete replicationsource <app> 2>/dev/null
kubectl -n <namespace> delete replicationdestination <app>-dst 2>/dev/null
kubectl -n <namespace> delete pvc volsync-src-<app>-cache 2>/dev/null
```

## One-Shot Recovery (restore component)

If a migration already happened and data was lost, use the `restore` component to recover from old VolSync snapshots:

Add to the app's `ks.yaml` temporarily:
```yaml
components:
  - ../../../../components/kopiur/backup
  - ../../../../components/kopiur/restore
postBuild:
  substitute:
    APP: *app
    KOPIUR_CAPACITY: 5Gi
    KOPIUR_HOSTNAME: <namespace>    # VolSync hostname identity
    KOPIUR_USERNAME: <app>          # VolSync username identity
    KOPIUR_SOURCE_PATH: /data       # VolSync source path
```

This creates a separate PVC `${APP}-kopiur-restore` populated from the old snapshot. Copy data from it to the main PVC, then remove the restore component.

## Rollback

If something goes wrong:
1. Swap component back to `../../../../components/volsync` in `ks.yaml`
2. Delete the kopiur PVC: `kubectl -n <namespace> delete pvc <app>`
3. Push — VolSync recreates the PVC from its ReplicationDestination
4. App resumes from last VolSync snapshot

VolSync's repository is untouched during the entire migration.

## Batch Migration Order (recommended)

Migrate one app per commit. Verify each before proceeding.

1. **Already done**: slink, lubelog, reaplet, autobrr, prowlarr, metube, picoshare, leafwiki
2. **Low-risk next**: thelounge, radicale, atuin, poznote, stirling-pdf
3. **Downloads**: bazarr, radarr, sonarr, readarr, lidarr, sabnzbd, qbittorrent
4. **Media**: audiobookshelf, navidrome, komga, tautulli, jellyseerr, plex
5. **Services**: paperless, karakeep, actual, mealie, homebox, n8n, docmost
6. **Critical (last)**: home-assistant, forgejo, kanidm

## What the kopiur/backup component creates

For each app, the component generates 4 resources (all named `${APP}`):

1. **SnapshotPolicy** — backup recipe: PVC source, retention (24h/7d/4w/3latest), truenas repo ref, zstd compression, identity adoption annotation
2. **SnapshotSchedule** — cron `H * * * *` (hourly with jitter)
3. **Restore** — volume populator source with `onMissingSnapshot: Continue`, credentialProjection
4. **PVC** — `dataSourceRef` pointing to the Restore CR, sized by `KOPIUR_CAPACITY`

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Restore resolves `NoSnapshot` | Identity mismatch or snapshot not in truenas repo | Check `allow-identity-change` annotation on SnapshotPolicy; verify snapshot exists with matching hostname/username |
| `PVC is invalid: spec is immutable` | Old PVC exists without `dataSourceRef` | Delete the old PVC |
| `credentials Secret does not exist` | Missing `kopiur/secret` component in namespace | Add to namespace `kustomization.yaml` |
| `Restore phase: Pending` | No claiming PVC with `dataSourceRef` | Check PVC spec references the Restore |
| Data loss after migration | Snapshots were in wrong repo or wrong identity | Use `kopiur/restore` component or manual kopia restore (see kopiur-restore skill) |
