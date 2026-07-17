---
name: migrate-volsync-to-kopiur
description: Migrate an app's PVC backup from VolSync to Kopiur with zero data loss
---

# Migrate VolSync to Kopiur

This skill migrates an app's PVC backup from VolSync (kopia mover / perfectra1n fork) to Kopiur. Because the fork writes a real kopia repository, kopiur **adopts it in place** — all existing snapshots are preserved and history continues seamlessly.

## Prerequisites

- Kopiur operator deployed and healthy (`kopiur-system` namespace)
- `ClusterRepository` named `truenas` in `Ready` state
- `components/kopiur/secret` included in the target namespace's `kustomization.yaml`
- `kubectl kopiur` plugin installed (`kubectl krew install kopiur/kopiur` or `brew install home-operations/tap/kopiur`)
- NFS export on TrueNAS writable by UID 1000

## Key Concept: Adoption vs Fresh Start

Since this cluster uses the **perfectra1n/volsync fork** (kopia mover, NOT restic), kopiur can adopt the existing kopia repository in place. This means:

- All existing snapshots are preserved
- Snapshot history continues (same identity)
- No parallel-run window needed for data safety
- The VolSync Secret is kept (kopiur references it)

If the cluster used upstream VolSync with **restic**, the repositories would be incompatible and kopiur would start fresh (empty repo). That is NOT our case.

## Workflow

### Step 1: Identify the target app

Gather:
1. App name (e.g., `autobrr`)
2. Namespace (e.g., `downloads`)
3. Current VolSync Secret name (usually `${APP}-volsync-secret`)

Verify kopiur operator health:
```bash
flux get hr -n kopiur-system kopiur
kubectl get clusterrepository truenas -o jsonpath='{.status.phase}'
```

### Step 2: Dry-run the migration with kubectl kopiur

Run the migration tool in dry-run mode to see what it will translate:

```bash
kubectl kopiur migrate volsync -n <namespace> --name <app> --repository truenas --repository-kind ClusterRepository
```

This prints:
- The accounting (every VolSync field mapped, unmapped, or ignored)
- The kopiur manifests it would create (SnapshotPolicy + SnapshotSchedule)

Review the accounting, especially the **pinned snapshot identity** line — it must match what `kopia snapshot list` shows for that app.

### Step 3: Offline/GitOps mode (alternative)

For a GitOps-native approach, point the tool at the VolSync YAML files directly:

```bash
kubectl kopiur migrate volsync \
  -f kubernetes/components/volsync/kopia/replicationsource.yaml \
  --repository truenas \
  --repository-kind ClusterRepository \
  --out-dir /tmp/kopiur-migration
```

This generates apply-ready YAML without touching the cluster.

### Step 4: Apply the migration (or swap the component)

**Option A: Use the CLI to apply directly**
```bash
kubectl kopiur migrate volsync -n <namespace> --name <app> --repository truenas --repository-kind ClusterRepository --apply
```

Then follow up by swapping the component in `ks.yaml` (Step 5).

**Option B: Swap the Flux component directly (preferred for GitOps)**

Since we already have the reusable `components/kopiur/backup` component that creates the SnapshotPolicy, SnapshotSchedule, Restore, and PVC, the cleanest path is:

Edit `kubernetes/apps/<namespace>/<app>/ks.yaml`:

```yaml
# Before
spec:
  components:
    - ../../../../components/volsync

# After
spec:
  components:
    - ../../../../components/kopiur/backup
```

Update `postBuild.substitute` if needed:
- Remove: `VOLSYNC_CAPACITY`, `VOLSYNC_ACCESSMODES`, `VOLSYNC_STORAGECLASS`
- Add (if non-default): `KOPIUR_CAPACITY`, `KOPIUR_ACCESSMODES`, `KOPIUR_STORAGECLASS`

Defaults:
- `KOPIUR_CAPACITY`: `5Gi`
- `KOPIUR_ACCESSMODES`: `ReadWriteOnce`
- `KOPIUR_STORAGECLASS`: `ceph-block`
- `KOPIUR_SNAPSHOTCLASS`: `csi-ceph-blockpool`
- `KOPIUR_PUID`: `1000`
- `KOPIUR_PGID`: `1000`

### Step 5: Delete the old PVC

The kopiur backup component creates a new PVC with `dataSourceRef` pointing to the `Restore` CR (volume populator). The old VolSync-managed PVC must be removed for the new one to be created.

```bash
kubectl -n <namespace> delete pvc <app>
```

Kopiur's `Restore` with `onMissingSnapshot: Continue` means:
- If kopiur repo has snapshots for this app → PVC is populated from the latest ✅
- If no snapshot exists yet → PVC is created empty (app starts fresh) ⚠️

**Important:** Since kopiur is using a NEW NFS repository (truenas:/mnt/tank/kopiur) rather than adopting the old VolSync filesystem repo, there will be NO existing snapshots in the new repo. The first backup cycle needs to complete before a restore can work.

Therefore, the safe order is:
1. Swap the component
2. Let the first SnapshotSchedule fire and succeed (check with `kubectl -n <namespace> get snapshots`)
3. THEN delete the old PVC (if needed for volume populator recreation)

Or simply: swap the component and let the existing PVC stay — kopiur will just start taking snapshots of it via the VolumeSnapshot copyMethod. The PVC only needs recreation if you want the volume populator `dataSourceRef` pattern for disaster recovery.

### Step 6: Retire VolSync resources

Once kopiur is taking snapshots successfully:

```bash
kubectl -n <namespace> delete replicationsource <app>-src 2>/dev/null
kubectl -n <namespace> delete replicationdestination <app>-dst 2>/dev/null
```

**KEEP the VolSync Secret** — it contains `KOPIA_PASSWORD` which is shared. The `kopiur-repository-secret` ExternalSecret handles this separately via the kopiur/secret component, so you can eventually remove the per-app volsync ExternalSecret too.

### Step 7: Verify

```bash
# Check kopiur snapshot succeeded
kubectl -n <namespace> get snapshots -l kopiur.home-operations.com/policy=<app>

# Check app is running
kubectl -n <namespace> get pods -l app.kubernetes.io/name=<app>

# Run doctor on the repository
kubectl kopiur doctor -n <namespace>
```

### Step 8: Commit and push

```bash
git add kubernetes/apps/<namespace>/<app>/
git commit -m "feat(<app>): migrate backup from volsync to kopiur"
git push
```

## Important Notes

### New NFS repo vs adopting old repo

This cluster's kopiur deployment uses a **new** NFS-backed `ClusterRepository` (`truenas:/mnt/tank/kopiur`), NOT adopting the existing VolSync filesystem repo. This means:

- Old VolSync snapshots remain in the old repo (accessible via VolSync until decommissioned)
- Kopiur starts with a fresh kopia repository on the NFS mount
- First backup for each app must complete before restore-from-kopiur works
- Both systems can run in parallel indefinitely (different repos, same password)

### If you want to adopt the existing repo instead

If you wanted kopiur to adopt the existing VolSync kopia repo (keeping all history), you would:
1. Point the `ClusterRepository` at the same backend VolSync uses
2. Use `kubectl kopiur migrate volsync --resolve-secrets --apply` to adopt in place
3. Delete VolSync's `KopiaMaintenance` / maintenance cronjobs (kopiur takes ownership)

This is more complex but preserves full snapshot history.

## Rollback

If something goes wrong:
1. Swap the component back to `../../../../components/volsync` in `ks.yaml`
2. If PVC was deleted: VolSync's `ReplicationDestination` recreates it from the volsync repo
3. Push — app resumes with last VolSync snapshot

VolSync's repository is untouched during the entire migration.

## Batch Migration Order

1. Non-critical: gotify, kromgo, gatus
2. Media: sonarr, radarr, bazarr, prowlarr
3. Downloads: autobrr, sabnzbd, qbittorrent
4. Critical: home-assistant, syncthing, paperless

One app per commit. Verify each before proceeding to the next.
