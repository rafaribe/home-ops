---
name: migrate-volsync-to-kopiur
description: Migrate an app's PVC backup from VolSync to Kopiur with zero data loss
---

# Migrate VolSync to Kopiur

This skill migrates an app's PVC backup from VolSync (perfectra1n/volsync fork with kopia mover) to Kopiur. The existing kopia repository is adopted in place — all snapshots are preserved.

## Prerequisites

Before migrating any app, verify:

```bash
# Kopiur operator healthy
kubectl get helmrelease -n kopiur-system kopiur
# ClusterRepository ready
kubectl get clusterrepository truenas -o jsonpath='{.status.phase}'
# Should output: Ready
```

The target namespace must include the `kopiur/secret` component in its `kustomization.yaml`:
```yaml
components:
  - ../../components/kopiur/secret
```

Namespaces already configured: `services`, `system-controllers`.
Namespaces that need it added before migration: `downloads`, `media`, `home`, `ai`, `database`, `games`, `security`, `storage`.

## Workflow

### Step 1: Verify the namespace has the kopiur secret component

Check `kubernetes/apps/<namespace>/kustomization.yaml` has:
```yaml
components:
  - ../../components/kopiur/secret
```

If missing, add it and commit. Verify the secret exists:
```bash
kubectl get secret kopiur-repository-secret -n <namespace>
```

### Step 2: Edit the app's `ks.yaml`

Replace the volsync component with kopiur:

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

The kopiur component creates the PVC named `${APP}` automatically.

### Step 4: Delete the old PVC

The kopiur backup component creates a PVC with `dataSourceRef` pointing to the `Restore` CR. The old VolSync PVC (which has no `dataSourceRef` or a different one) must be deleted:

```bash
kubectl -n <namespace> delete pvc <app>
```

If the PVC is stuck in `Terminating`:
```bash
kubectl -n <namespace> patch pvc <app> -p '{"metadata":{"finalizers":null}}' --type=merge
```

The app pod will restart. Kopiur's Restore with `onMissingSnapshot: Continue` means:
- If kopiur repo has snapshots → PVC populated from latest ✅
- If no snapshot exists → PVC created empty, app starts fresh ✅

### Step 5: Commit, push, reconcile

```bash
git add kubernetes/apps/<namespace>/<app>/
git commit -m "feat(<app>): migrate backup from volsync to kopiur"
git push
flux reconcile source git flux-system
flux reconcile ks <app> -n <namespace>
```

### Step 6: Verify

```bash
# Kustomization reconciled
kubectl get kustomization -n <namespace> <app>

# Kopiur CRDs created
kubectl get snapshotpolicy,snapshotschedule,restore -n <namespace> | grep <app>

# PVC bound
kubectl get pvc -n <namespace> <app>

# Pod running
kubectl get pods -n <namespace> -l app.kubernetes.io/name=<app>

# First snapshot (after cron fires, usually within the hour)
kubectl get snapshot -n <namespace> -l kopiur.home-operations.com/policy=<app>
```

### Step 7: Clean up VolSync resources (optional, after verified)

```bash
kubectl -n <namespace> delete replicationsource <app> 2>/dev/null
kubectl -n <namespace> delete replicationdestination <app>-dst 2>/dev/null
```

The per-app volsync ExternalSecret (`<app>-volsync`) can be removed from git later during full decommission.

## What the kopiur/backup component creates

For each app, the component generates 4 resources (all named `${APP}`):

1. **SnapshotPolicy** — backup recipe: PVC source, retention (24h/7d/4w/3latest), repository ref
2. **SnapshotSchedule** — cron `H * * * *` (hourly with jitter)
3. **Restore** — volume populator source with `onMissingSnapshot: Continue`
4. **PVC** — `dataSourceRef` pointing to the Restore CR, sized by `KOPIUR_CAPACITY`

## Rollback

If something goes wrong:
1. Swap component back to `../../../../components/volsync` in `ks.yaml`
2. Delete the kopiur PVC: `kubectl -n <namespace> delete pvc <app>`
3. Push — VolSync recreates the PVC from its ReplicationDestination
4. App resumes from last VolSync snapshot

VolSync's repository is untouched during the entire migration.

## Batch Migration Order (recommended)

Migrate one app per commit. Verify each before proceeding.

1. **Already done**: slink, lubelog, reaplet
2. **Low-risk pilots**: autobrr, prowlarr, metube, picoshare, leafwiki
3. **Downloads**: bazarr, radarr, sonarr, readarr, lidarr, sabnzbd, qbittorrent
4. **Media**: audiobookshelf, navidrome, komga, tautulli, jellyseerr
5. **Services**: paperless, karakeep, actual, mealie, homebox, n8n
6. **Critical (last)**: home-assistant, immich, forgejo, kanidm

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `SnapshotPolicy dry-run failed: field not declared` | Component template field in wrong location | Check component YAML against CRD schema |
| `PVC is invalid: spec is immutable` | Old PVC exists without `dataSourceRef` | Delete the old PVC |
| `credentials Secret does not exist` | Missing `kopiur/secret` component in namespace | Add to namespace `kustomization.yaml` |
| `Restore phase: Pending` | No snapshot yet OR missing credentials | Check secret exists, wait for first cron |
