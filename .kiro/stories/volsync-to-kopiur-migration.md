# VolSync → Kopiur Migration Status

**Last updated:** 2026-07-18

## Overview

Migration from VolSync (kopia mover) to Kopiur for PVC backups. Kopiur uses a **new NFS-backed `ClusterRepository`** (`truenas:/mnt/tank/kopiur`) — it does NOT adopt the old VolSync kopia repo. Old VolSync snapshots remain in the old repo until decommissioned.

## Infrastructure Status

| Component | Status | Notes |
|-----------|--------|-------|
| Kopiur operator | ✅ Healthy | v0.7.5, `kopiur-system` namespace |
| ClusterRepository `truenas` | ✅ Ready | NFS-backed |
| `components/kopiur/backup` | ✅ Available | Creates SnapshotPolicy, SnapshotSchedule, Restore, PVC |
| `components/kopiur/secret` | ✅ Available | ExternalSecret for repo credentials |

## Migration Progress

### ✅ Completed (3 apps)

| App | Namespace | Status | Notes |
|-----|-----------|--------|-------|
| **reaplet** | system-controllers | ✅ Working | Hourly snapshots succeeding consistently |
| **slink** | services | ✅ Working | Hourly snapshots succeeding consistently |
| **lubelog** | services | ⚠️ Partially broken | See issues below |

### ❌ Not Started — Gotify

Gotify was included in the migration commit (`46dcdf72dd`) but **the `ks.yaml` was never added to `kubernetes/apps/observability/kustomization.yaml` resources list**. Flux doesn't reconcile it, so no kopiur resources exist in the `observability` namespace.

**Fix:** Add `- ./gotify/ks.yaml` to `kubernetes/apps/observability/kustomization.yaml` resources.

### 🚫 Remaining (74 apps still on VolSync)

See full list in the investigation output. Recommended batch order from SKILL.md:
1. Non-critical: ~~gotify~~, kromgo, gatus
2. Media: sonarr, radarr, bazarr, prowlarr
3. Downloads: autobrr, sabnzbd, qbittorrent
4. Critical: home-assistant, syncthing, paperless

## Known Issues

### 1. Lubelog: Stuck PVC `lubelog-v2` causing snapshot failures

**Symptom:** Last 2 hourly snapshots failing with:
```
cannot add finalizer on claim because it is being deleted
```

**Root cause:** The old PVC `lubelog-v2` is stuck in `Terminating` state (since 2026-07-17T10:58:39Z) because the lubelog pod is still mounting it (`pvc-protection` finalizer). Meanwhile, the kopiur SnapshotPolicy is trying to snapshot this PVC.

**Details:**
- `ks.yaml` has `CLAIM: lubelog-v2` (a custom substitution variable, but the kopiur component uses `${APP}` = `lubelog` for both PVC name and snapshot source)
- The kopiur backup component created a **new** PVC named `lubelog` via volume populator
- The HelmRelease still references `existingClaim: lubelog-v2` (the old PVC)
- The old `lubelog-v2` PVC was marked for deletion but can't complete because the pod is using it
- Kopiur's SnapshotPolicy `sources[].pvc.name` is `lubelog` (from `${APP}`), which is the new empty PVC — but VolumeSnapshot is somehow still targeting `lubelog-v2`

**Fix needed:**
1. Update `helmrelease.yaml` to use `existingClaim: lubelog` (the new kopiur-managed PVC)
2. Restart the pod so it releases the old `lubelog-v2` PVC
3. The old PVC will then complete deletion
4. Remove the `CLAIM: lubelog-v2` variable from `ks.yaml` (it's no longer needed)
5. Ensure data was copied from `lubelog-v2` to `lubelog` (check if the kopiur Restore populated the new PVC from old snapshots, or if it started empty)

### 2. Gotify: Not wired into Flux

See above — missing resource entry in namespace kustomization.

### 3. Early failures on all 3 apps (first ~3 hours)

All three migrated apps had their first 3 snapshots fail, then started succeeding. This aligns with the migration commit time (02:12 UTC) — likely Kopiur needed to initialize the repo structure on the NFS backend before snapshots could succeed. Not actionable — self-resolved.

## Architecture Notes

- Kopiur `SnapshotPolicy` defines: copyMethod (Snapshot), retention, mover securityContext, repository ref, volumeSnapshotClassName
- Kopiur `SnapshotSchedule` defines: cron (`H * * * *` = jittered hourly), policyRef, history limits
- Kopiur `Restore` CR: used as `dataSourceRef` on the PVC for volume populator pattern (disaster recovery)
- `onMissingSnapshot: Continue` means fresh PVC if no snapshot exists in the new repo
- VolSync resources (ReplicationSource/Destination) should be cleaned up after kopiur is confirmed working per-app
