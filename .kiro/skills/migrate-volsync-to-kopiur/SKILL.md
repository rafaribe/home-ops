---
name: migrate-volsync-to-kopiur
description: Migrate an app's PVC backup from VolSync to Kopiur with zero data loss
---

# Migrate VolSync to Kopiur

This skill migrates an app's PVC backup from VolSync (kopia mover) to Kopiur (kopia-native operator) with zero data loss. The strategy runs both systems in parallel during a transition window, then atomically swaps.

## Prerequisites

- Kopiur operator deployed and healthy (`kopiur-system` namespace)
- `ClusterRepository` named `truenas` in `Ready` state
- `components/kopiur/secret` included in the target namespace's `kustomization.yaml`
- The `kopiur-repository-secret` ExternalSecret synced in the target namespace
- NFS export on TrueNAS writable by UID 1000 (`chown -R 1000:1000 /mnt/tank/kopiur`)

## Workflow

### Step 1: Identify the target app

Gather:
1. App name (e.g., `autobrr`)
2. Namespace (e.g., `downloads`)
3. Current PVC name (usually `${APP}`)
4. Current PVC capacity (check the volsync component's `VOLSYNC_CAPACITY` substitute or the live PVC)
5. VolumeSnapshotClass in use (usually `csi-ceph-blockpool`)

Verify the app currently uses the volsync component:
```bash
grep -r "volsync" kubernetes/apps/<namespace>/<app>/ks.yaml
```

Verify kopiur operator health:
```bash
flux get hr -n kopiur-system kopiur
kubectl get clusterrepository truenas -o jsonpath='{.status.phase}'
```

Both must show healthy/Ready before proceeding.

### Step 2: Add kopiur SnapshotPolicy targeting the existing PVC

Create a temporary `SnapshotPolicy` + `SnapshotSchedule` that backs up the **existing** VolSync-managed PVC to the kopiur repository. This runs alongside VolSync — both snapshot the same live PVC.

Create `kubernetes/apps/<namespace>/<app>/app/kopiur-migration.yaml`:

```yaml
---
apiVersion: kopiur.home-operations.com/v1alpha1
kind: SnapshotPolicy
metadata:
  name: <app>
spec:
  mover:
    securityContext:
      runAsGroup: ${KOPIUR_PGID:=1000}
      runAsUser: ${KOPIUR_PUID:=1000}
  repository:
    kind: ClusterRepository
    name: truenas
  retention:
    keepDaily: 7
    keepHourly: 24
    keepLatest: 3
    keepWeekly: 4
  sources:
    - pvc:
        name: <app>
        volumeSnapshotClassName: csi-ceph-blockpool
---
apiVersion: kopiur.home-operations.com/v1alpha1
kind: SnapshotSchedule
metadata:
  name: <app>
spec:
  policyRef:
    name: <app>
  schedule:
    cron: H * * * *
```

Add it to the app's `kustomization.yaml` resources.

### Step 3: Wait for kopiur snapshots to land

Push the change and let at least 2-3 backup cycles complete. Verify:

```bash
kubectl -n <namespace> get snapshots -l kopiur.home-operations.com/policy=<app>
```

Confirm at least one `Succeeded` snapshot exists with non-zero `bytesNew`:

```bash
kubectl -n <namespace> get snapshot <name> -o jsonpath='{.status.stats}'
```

If using the kubectl plugin:
```bash
kubectl kopiur status -n <namespace> <app>
```

### Step 4: Swap the component in ks.yaml

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

The defaults are:
- `KOPIUR_CAPACITY`: `5Gi`
- `KOPIUR_ACCESSMODES`: `ReadWriteOnce`
- `KOPIUR_STORAGECLASS`: `ceph-block`
- `KOPIUR_SNAPSHOTCLASS`: `csi-ceph-blockpool`
- `KOPIUR_PUID`: `1000`
- `KOPIUR_PGID`: `1000`

### Step 5: Remove the migration manifest

Delete the temporary `kopiur-migration.yaml` from the app directory — the `components/kopiur/backup` component now provides the `SnapshotPolicy` and `SnapshotSchedule` via substitution variables.

Remove it from the app's `kustomization.yaml` resources too.

### Step 6: Delete the old PVC

The kopiur backup component creates a new PVC with `dataSourceRef` pointing to the `Restore` CR (volume populator). The old VolSync-managed PVC must be removed for the new one to be created.

**This is the only destructive step.** The kopiur `Restore` with `onMissingSnapshot: Continue` means:
- If kopiur has a snapshot → PVC is populated from it ✅
- If no snapshot exists → PVC is created empty (app starts fresh) ⚠️

This is why Step 3 (verify snapshots exist) is critical.

```bash
kubectl -n <namespace> delete pvc <app>
```

Flux will reconcile and create the new PVC via kopiur's volume populator.

### Step 7: Verify the app is running with restored data

```bash
kubectl -n <namespace> get pvc <app>
kubectl -n <namespace> get pods -l app.kubernetes.io/name=<app>
```

Check the app UI/logs to confirm data is intact.

### Step 8: Clean up VolSync resources

Once confirmed working, the old VolSync `ReplicationSource` and `ReplicationDestination` CRs may still exist if they were not managed by the component. Check and remove:

```bash
kubectl -n <namespace> get replicationsource,replicationdestination
kubectl -n <namespace> delete replicationsource <app>-src
kubectl -n <namespace> delete replicationdestination <app>-dst
```

Also delete the per-app volsync ExternalSecret if it was created by the volsync component:
```bash
kubectl -n <namespace> delete externalsecret <app>-volsync
```

### Step 9: Commit and push

Commit the final state (ks.yaml with kopiur component, no migration manifest, no volsync references).

```
git add kubernetes/apps/<namespace>/<app>/
git commit -m "feat(<app>): migrate backup from volsync to kopiur"
git push
```

## Rollback

If something goes wrong after the PVC swap:

1. Change the component back to `../../../../components/volsync` in `ks.yaml`
2. Delete the kopiur-managed PVC
3. Push — VolSync's `ReplicationDestination` will recreate the PVC from the volsync kopia repo
4. The app resumes with the last VolSync snapshot

This works as long as VolSync's repository still has valid snapshots (they are untouched during migration).

## Batch migration

For migrating many apps, repeat Steps 2-9 per app. Recommended order:
1. Start with non-critical apps (gotify, kromgo, etc.)
2. Move to media apps (sonarr, radarr, etc.)
3. Finish with critical/stateful apps (home-assistant, databases)

Do NOT migrate all apps in one commit — do them one at a time to contain blast radius.

## Notes

- VolSync and kopiur use **separate kopia repositories** on different backends. Existing VolSync snapshots are not visible to kopiur and vice versa.
- The `kopiur/secret` component must be included in the namespace's top-level `kustomization.yaml` (as a component) for the `kopiur-repository-secret` to be available.
- The `KOPIA_PASSWORD` is shared between both systems (same akeyless key `volsync`), but the repositories are independent.
- kopiur's `Restore` with `onMissingSnapshot: Continue` makes this GitOps-safe — deploying the component on a fresh cluster without snapshots won't block app startup.
- After full migration, VolSync can be removed from the cluster entirely (remove from `storage/volsync`).
