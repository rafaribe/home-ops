# VolSync → Kopiur Migration (Adopt-in-Place Strategy)

## Overview

Migrate all apps from VolSync (perfectra1n fork, kopia mover, NFS backend on TrueNAS)
to Kopiur by **adopting the existing kopia repository in place**. Both systems run in
parallel during the transition. Kopiur writes to the same repository with matched
identities so kopia deduplicates against the existing data — no re-upload, no data loss.

Once Kopiur has proven itself over several days, VolSync is removed and Kopiur takes
full ownership. A `RepositoryReplication` mirrors the NFS repo to TrueNAS Garage S3
for offsite durability.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Cluster (Ceph RBD PVCs)                                     │
│                                                             │
│  VolSync ReplicationSource ──┐                              │
│  (hourly kopia mover)        │  same kopia repo             │
│                              ├──► NFS: truenas:/mnt/tank/   │
│  Kopiur SnapshotPolicy ──────┘       volsync-kopia          │
│  (hourly CSI snapshot + kopia)                              │
│                                                             │
│  Kopiur RepositoryReplication ──► Garage S3 (TrueNAS app)   │
│  (offsite mirror)                  10.0.0.6:3900            │
│                                    bucket: kopiur-backups    │
└─────────────────────────────────────────────────────────────┘
```

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Adopt existing NFS repo, don't create new | Preserves all snapshot history, dedup works |
| Pin identity to `<app>@<namespace>:/data` | Matches VolSync fork's identity pattern exactly |
| `sourcePathOverride: /data` on SnapshotPolicy | VolSync mounts PVC at `/data`, kopia records that path |
| `takeoverPolicy: Force` on Maintenance | VolSync's KopiaMaintenance will be stopped |
| `catalog.periodicRefresh: true` | See VolSync's new snapshots during transition |
| Use `snapshot-only` component (no PVC/Restore) | VolSync still owns the PVC lifecycle |

## Identity Model

VolSync fork records snapshots as:
```
username: <app-name>       (e.g. navidrome)
hostname: <namespace>      (e.g. media)
path:     /data
```

Kopiur's default would be `<app>@<namespace>:/pvc/<app>` which does NOT match.
The `snapshot-only` component pins the identity explicitly:
```yaml
identity:
  username: ${APP}
  hostname: ${KOPIUR_IDENTITY_HOSTNAME}   # set to namespace in each ks.yaml
  sourcePath: /data
sources:
  - pvc:
      name: ${CLAIM:=${APP}}
    sourcePathOverride: /data
```

## Components

### `components/kopiur/snapshot-only/`

Creates only SnapshotPolicy + SnapshotSchedule (no PVC, no Restore).
Used alongside VolSync during the parallel-run phase.

Files:
- `kustomization.yaml` — Component definition
- `snapshotpolicy.yaml` — Identity-pinned policy targeting `truenas` ClusterRepository
- `snapshotschedule.yaml` — Hourly cron with jitter

### Variables required in `ks.yaml`

| Variable | Required | Example | Purpose |
|----------|----------|---------|---------|
| `APP` | yes | `navidrome` | App name, used as PVC name and identity username |
| `KOPIUR_IDENTITY_HOSTNAME` | yes | `media` | Must equal the namespace (VolSync identity match) |
| `VOLSYNC_CAPACITY` | yes | `5Gi` | Existing VolSync PVC size |
| `KOPIUR_SNAPSHOTCLASS` | no | `csi-ceph-blockpool` | Default works |
| `KOPIUR_PUID` / `KOPIUR_PGID` | no | `1000` | Default works |

### Example `ks.yaml` (parallel mode)

```yaml
spec:
  dependsOn:
    - name: kopiur
      namespace: kopiur-system
    - name: rook-ceph-cluster
      namespace: rook-ceph
  components:
    - ../../../../components/volsync
    - ../../../../components/kopiur/snapshot-only
  postBuild:
    substitute:
      APP: *app
      VOLSYNC_CAPACITY: 5Gi
      KOPIUR_IDENTITY_HOSTNAME: <namespace>
```

## How to Apply to All Apps

For each app in each namespace:

1. Add `dependsOn` for `kopiur` and `rook-ceph-cluster`
2. Add `../../../../components/kopiur/snapshot-only` to `components`
3. Add `KOPIUR_IDENTITY_HOSTNAME: <namespace>` to `postBuild.substitute`
4. Ensure the namespace has `kopiur/secret` component (for credentials)

Namespaces needing `kopiur/secret` added to their `kustomization.yaml`:
- ai, database, development, games, home, security, storage
- (downloads, media, services already have it)

## How to Verify

### 1. Check ClusterRepository adoption

```bash
kubectl get clusterrepository truenas -o jsonpath='{.status.phase}'
# Expected: Ready

kubectl get clusterrepository truenas -o jsonpath='{.status.catalog}'
# Expected: discoveredBackupCount > 0 after first scan
```

### 2. Check Maintenance takeover

```bash
kubectl get maintenance -n kopiur-system truenas
# Expected: OWNED = true

kubectl get maintenance -n kopiur-system truenas -o jsonpath='{.status.conditions[?(@.type=="Owned")].status}'
# Expected: True
```

### 3. Check discovered snapshots appear

```bash
kubectl get snapshots -A -l kopiur.home-operations.com/origin=discovered --no-headers | wc -l
# Expected: > 0 (VolSync's existing snapshots materialized as CRs)
```

### 4. Check per-app SnapshotPolicy is healthy

```bash
kubectl get snapshotpolicy -A
# Each app should show REPOSITORY=truenas

kubectl get snapshotpolicy -n media navidrome -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'
# Expected: True
```

### 5. Check first Kopiur snapshot completes

```bash
kubectl get snapshot -A --sort-by=.metadata.creationTimestamp | tail -10
# Should see snapshots appearing after the hourly cron fires

kubectl get snapshot -n media -l kopiur.home-operations.com/policy=navidrome
# Expected: at least one with PHASE=Succeeded
```

### 6. Verify dedup is working (not re-uploading)

```bash
kubectl get snapshot -n media <snapshot-name> -o jsonpath='{.status.stats}'
# bytesNew should be SMALL (only changed data, not full PVC size)
# If bytesNew ≈ PVC size, identity mismatch — check username/hostname/path
```

### 7. Check VolSync still works independently

```bash
kubectl get replicationsource -n media navidrome -o jsonpath='{.status.latestMoverStatus.result}'
# Expected: Successful

kubectl get replicationsource -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,RESULT:.status.latestMoverStatus.result' | grep -v Successful
# Should be empty (all apps still backing up via VolSync)
```

## Cutover (After Several Days of Parallel Operation)

Once satisfied that Kopiur snapshots are healthy across all apps:

1. **Stop VolSync maintenance**: Delete the `KopiaMaintenance` CR in `storage` namespace
2. **Remove VolSync components from all `ks.yaml`**: Swap to `components/kopiur/backup` (adds PVC + Restore)
3. **Delete old PVCs**: Each app restarts with Kopiur's Restore populating from the adopted repo
4. **Remove VolSync HelmRelease**: Delete from Git, let Flux prune it
5. **Clean up**: Remove per-app `<app>-volsync` ExternalSecrets, MutatingAdmissionPolicies
6. **Set up RepositoryReplication**: Mirror `truenas` → `garage-s3` for offsite

## Rollback

If Kopiur has issues during parallel operation:
- Remove `kopiur/snapshot-only` component from `ks.yaml` files
- VolSync continues unaffected (it never stopped)
- The adopted repo is unchanged (Kopiur with `Retain` policy never deletes discovered data)

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `MissingCredentialsSecret` | Namespace lacks `kopiur/secret` component | Add to namespace `kustomization.yaml` |
| `CredentialsAvailable: False` | Secret not synced from Akeyless | Check ExternalSecret status |
| `bytesNew` equals full PVC size | Identity mismatch | Verify `KOPIUR_IDENTITY_HOSTNAME` = namespace |
| `IndexBlobHealth: TooManyIndexBlobs` | Maintenance hasn't compacted yet | Wait for next scheduled run, or trigger manually |
| Maintenance `Owned: False` | Lease conflict with VolSync | Ensure VolSync `KopiaMaintenance` is deleted and `takeoverPolicy: Force` |
| DNS resolution failures in mover pods | Cluster DNS can't resolve NFS hostname | Use IP in ClusterRepository endpoint (already done for garage-s3) |
