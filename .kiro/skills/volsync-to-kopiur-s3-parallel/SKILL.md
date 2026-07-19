---
name: volsync-to-kopiur-s3-parallel
description: Run Kopiur S3 backups alongside VolSync NFS, verify over days, then cutover with full restore from S3
argument-hint: "[namespace/app or 'all'] - Scope of the migration"
---

# VolSync → Kopiur S3 Migration (Parallel Strategy)

## Overview

Run Kopiur (S3 target on TrueNAS Garage) alongside VolSync (NFS target on TrueNAS)
for all apps simultaneously. Verify S3 backups are healthy over several days.
Then perform a full cutover: delete all PVCs and restore from S3 backups.

No data loss. Minimal downtime (only during final cutover).

## Architecture

```
Phase 1 (parallel):
  App PVC ←── VolSync ReplicationSource (hourly) ──→ NFS: truenas:/mnt/tank/volsync-kopia
  App PVC ←── Kopiur SnapshotPolicy (hourly) ──────→ S3: 10.0.0.6:3900/kopiur-backups

Phase 2 (cutover):
  App PVC ←── Kopiur Restore (from S3) ←────────────── S3: 10.0.0.6:3900/kopiur-backups
```

## Infrastructure

| Component | Target | Endpoint |
|-----------|--------|----------|
| VolSync (existing) | TrueNAS NFS | `truenas.rafaribe.com:/mnt/tank/volsync-kopia` |
| Kopiur `garage-s3` | TrueNAS Garage S3 app | `10.0.0.6:3900` bucket `kopiur-backups` |
| Credentials | Akeyless key `kopiur` | `kopiur-garage-creds` Secret |

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Fresh S3 repo, don't adopt NFS | NFS repo has 7900+ index blobs (degraded). Fresh repo = clean start |
| `credentialProjection.allowed: true` | ClusterRepository auto-copies S3 creds to app namespaces |
| `identityDefaults` via CEL | No per-app identity vars needed. `policyName@namespace:/pvc/<pvc>` |
| `sourceColocation.mode: Auto` | Mover pins to same node as RWO PVC (no Multi-Attach errors) |
| `parameters.epoch.minDuration: 6h` | Faster index compaction than kopia's 24h default |
| `deletionProtection.threshold: 25` | Safety during mass cutover operations |
| `snapshot-only` component | Only SnapshotPolicy + SnapshotSchedule. No PVC, no Restore |

## Prerequisites

```bash
# Kopiur operator healthy
kubectl get helmrelease -n kopiur-system kopiur
# Should be: True

# garage-s3 ClusterRepository ready
kubectl get clusterrepository garage-s3 -o jsonpath='{.status.phase}'
# Should output: Ready

# TrueNAS Garage S3 reachable
kubectl run --rm -it s3-test --image=curlimages/curl --restart=Never \
  --overrides='{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"s3-test","image":"curlimages/curl","command":["curl","-s","-o","/dev/null","-w","%{http_code}","http://10.0.0.6:3900/"],"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}}]}}'
# Should output: 403 (reachable, unsigned request rejected = correct)
```

## Phase 1: Add Kopiur Alongside VolSync

### The `snapshot-only` component

Location: `kubernetes/components/kopiur/snapshot-only/`

Creates only:
- **SnapshotPolicy** — targets `garage-s3`, `credentialProjection.enabled: true`, hourly retention
- **SnapshotSchedule** — `H * * * *` (hourly with jitter)

Does NOT create PVC or Restore (VolSync still owns the PVC).

### For each VolSync app's `ks.yaml`

Add to `spec.components`:
```yaml
components:
  - ../../../../components/volsync
  - ../../../../components/kopiur/snapshot-only
```

Add to `spec.dependsOn` (if not present):
```yaml
dependsOn:
  - name: kopiur
    namespace: kopiur-system
  - name: rook-ceph-cluster
    namespace: rook-ceph
```

No additional variables needed. The existing `APP` variable is sufficient.

### Batch update (all apps at once)

```bash
cd /home/rafaribe/code/rafaribe/home-ops
for f in $(grep -rl "components/volsync" kubernetes/apps/*/*/ks.yaml); do
  if grep -q "kopiur/snapshot-only" "$f"; then continue; fi
  yq -i '.spec.components += ["../../../../components/kopiur/snapshot-only"]' "$f"
  has_kopiur=$(yq '.spec.dependsOn[] | select(.name == "kopiur")' "$f" 2>/dev/null)
  if [ -z "$has_kopiur" ]; then
    yq -i '.spec.dependsOn = (.spec.dependsOn // []) + [{"name": "kopiur", "namespace": "kopiur-system"}, {"name": "rook-ceph-cluster", "namespace": "rook-ceph"}]' "$f"
  fi
done
```

### Commit and push

```bash
git add kubernetes/apps/*/*/ks.yaml
git commit -m "feat(kopiur): add S3 snapshot-only backup to all VolSync apps"
git push
flux reconcile source git flux-system
```

## Phase 1 Verification

### Check all SnapshotPolicies are Ready

```bash
kubectl get snapshotpolicy -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}: {.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep -v True
# Should be empty (all True)
```

### Check SnapshotSchedules are active

```bash
kubectl get snapshotschedule -A
# All should show a SCHEDULE column with "H * * * *"
```

### Wait for first snapshots (within 1 hour)

```bash
kubectl get snapshot -A --sort-by=.metadata.creationTimestamp -l kopiur.home-operations.com/origin!=discovered | tail -20
# Should see snapshots appearing with PHASE=Succeeded
```

### Verify dedup and size

```bash
kubectl get snapshot -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}: bytes={.status.stats.sizeBytes} new={.status.stats.bytesNew}{"\n"}{end}' | tail -10
# bytesNew should decrease after the first full backup (dedup working)
```

### Monitor over several days

```bash
# Check for failed snapshots
kubectl get snapshot -A --field-selector=status.phase=Failed

# Check repository health
kubectl get clusterrepository garage-s3 -o jsonpath='{.status.conditions[?(@.type=="IndexBlobHealth")].status}'
# Should be: True

# Check repo size growing
kubectl get clusterrepository garage-s3 -o jsonpath='{.status.storageStats}'
```

## Phase 2: Cutover (After Days of Verification)

Once satisfied that S3 backups are healthy:

### Step 1: Switch all apps from VolSync to Kopiur full

For each app's `ks.yaml`, replace:
```yaml
components:
  - ../../../../components/volsync
  - ../../../../components/kopiur/snapshot-only
```
With:
```yaml
components:
  - ../../../../components/kopiur/backup
```

And replace `VOLSYNC_CAPACITY` with `KOPIUR_CAPACITY` in `postBuild.substitute`.

### Step 2: Delete all old PVCs

```bash
# For each namespace with migrated apps:
for ns in downloads media services home ai database games development storage security; do
  for pvc in $(kubectl get pvc -n $ns -l kustomize.toolkit.fluxcd.io/name -o name 2>/dev/null); do
    echo "Deleting $ns/$pvc"
    kubectl delete $pvc -n $ns
  done
done
```

### Step 3: Flux recreates PVCs from Kopiur Restore (S3)

Each app's PVC is recreated with `dataSourceRef: kopiur.home-operations.com/Restore/<app>`.
Kopiur's Restore populates from the latest S3 snapshot. Apps restart automatically.

### Step 4: Remove VolSync

```bash
# Git: remove VolSync HelmRelease, MutatingAdmissionPolicies, per-app ExternalSecrets
# Cluster: Flux prunes VolSync resources on reconcile
```

## Phase 2 Verification

```bash
# All PVCs bound
kubectl get pvc -A -l app.kubernetes.io/name | grep -v Bound

# All pods running
kubectl get pods -A -l app.kubernetes.io/name --field-selector=status.phase!=Running | grep -v Completed

# Restores completed
kubectl get restore -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}: {.status.phase}{"\n"}{end}' | grep -v Completed

# No VolSync resources remain
kubectl get replicationsource -A
kubectl get replicationdestination -A
# Should be empty
```

## Rollback

### During Phase 1 (parallel operation)

Remove `kopiur/snapshot-only` from `ks.yaml` files. VolSync continues unaffected.
S3 snapshots are retained (Kopiur never deletes what it created unless retention says so).

### During Phase 2 (cutover)

1. Swap components back to `../../../../components/volsync`
2. Delete kopiur PVCs
3. Push — VolSync recreates PVCs from its ReplicationDestination (NFS backup)
4. VolSync's NFS repository is untouched through the entire process

## ClusterRepository Configuration

File: `kubernetes/apps/kopiur-system/kopiur/repository/clusterrepository-garage.yaml`

```yaml
apiVersion: kopiur.home-operations.com/v1alpha1
kind: ClusterRepository
metadata:
  name: garage-s3
spec:
  allowedNamespaces:
    all: true
  backend:
    s3:
      bucket: kopiur-backups
      endpoint: 10.0.0.6:3900
      region: us-east-1
      tls:
        disableTls: true
      auth:
        secretRef:
          name: kopiur-garage-creds
          namespace: kopiur-system
  create:
    enabled: true
  credentialProjection:
    allowed: true
  deletionProtection:
    threshold: 25
  encryption:
    passwordSecretRef:
      name: kopiur-garage-creds
      namespace: kopiur-system
      key: KOPIA_PASSWORD
  identityDefaults:
    hostnameExpr: "namespace"
    usernameExpr: "policyName"
  maintenance:
    enabled: true
    schedule:
      full: { cron: "0 3 * * *", jitter: 1h }
      quick: { cron: "0 */6 * * *", jitter: 30m }
  moverDefaults:
    podSecurityContext:
      fsGroup: 1000
      runAsGroup: 1000
      runAsUser: 1000
    sourceColocation:
      mode: Auto
  parameters:
    epoch:
      minDuration: 6h
  scheduleDefaults:
    timezone: Europe/Lisbon
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `CredentialsAvailable: False` | `credentialProjection` not working | Check `credentialProjection.allowed: true` on ClusterRepository AND `enabled: true` on SnapshotPolicy |
| DNS resolution failure in mover | Cluster DNS can't resolve hostname | Use IP address in endpoint (already done: `10.0.0.6:3900`) |
| `region mismatch` in S3 signature | Client region ≠ server s3_region | Ensure ClusterRepository `region` matches Garage's `s3_region` config |
| `RepositoryNotInitialized` | `create.enabled` not taking effect | Delete ClusterRepository, let Flux recreate (operator caches stale bootstrap state) |
| `Multi-Attach error` for mover pod | RWO PVC on different node | `sourceColocation.mode: Auto` should prevent this; check node affinity |
| SnapshotPolicy not creating snapshots | Schedule hasn't fired yet | Wait for `H * * * *` cron (up to 1 hour). Check `kubectl get snapshotschedule -A` |
| `IndexBlobHealth: TooManyIndexBlobs` | Fresh repo shouldn't have this | Check `parameters.epoch.minDuration` is set. Wait for first maintenance run |
| `${APP}` not substituted | App KS missing `postBuild.substitute.APP` | Add `APP: *app` to the app's ks.yaml postBuild |
