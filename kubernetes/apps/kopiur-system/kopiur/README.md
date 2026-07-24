# Kopiur Migration Scripts

## fix-terminating-pvcs.py

Fixes PVCs stuck in `Terminating` state after migrating from VolSync to Kopiur.

### When to use

During the volsync→kopiur migration, if the `kopiur/backup` component is applied without the `IfNotPresent` SSA label on the PVC template, Flux will attempt to delete existing PVCs (because `spec.dataSourceRef` is immutable and changed from `ReplicationDestination` to `Restore`). The `kubernetes.io/pvc-protection` finalizer blocks deletion while pods are running, leaving PVCs stuck in `Terminating` forever.

### What it does

For each Terminating PVC:

1. Finds the owning Deployment
2. Scales down to 0 replicas
3. Waits for pods to stop (max 60s, 10s checks)
4. Removes the `pvc-protection` finalizer
5. Waits for PVC to be fully deleted
6. Triggers a Flux reconcile (via annotation) to recreate the PVC with the kopiur `dataSourceRef`
7. Waits for the new PVC to bind (max 30s)
8. Scales the Deployment back up
9. Verifies pod is starting

### Limitations

- Only handles **Deployments**. CronJobs (e.g. `kometa`) and StatefulSets (e.g. `obsidian-couchdb`) need manual handling.
- PVCs in `Pending` after the script runs are normal — the Kopiur Restore populator needs time to provision them from kopia snapshots.
- If many restores run simultaneously, the Ceph provisioner may back up. Failed Restores auto-retry or can be deleted to re-trigger.

### Usage

```bash
python3 fix-terminating-pvcs.py
```

Logs are written to `fix-terminating-pvcs.log` in the same directory.

### PVC name → app name mapping

Some PVCs have names that don't match their Deployment. The script handles these:

| PVC name | App/Deployment |
|----------|---------------|
| `forgejo-data` | `forgejo` |
| `pgadmin-v2` | `pgadmin` |
| `actual-data` | `actual` |
| `kitchenowl-data` | `kitchenowl` |
| `radicale-data-v2` | `radicale` |
| `plex-data` | `plex` |
| `jellyfin-v2` | `jellyfin` |

### Manual fixes for non-Deployment workloads

**CronJob (e.g. kometa):**
```bash
kubectl delete job <active-job> -n <ns> --force
kubectl patch pvc <name> -n <ns> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl annotate ks <name> -n <ns> reconcile.fluxcd.io/requestedAt=$(date +%s) --overwrite
```

**StatefulSet (e.g. obsidian-couchdb):**
```bash
kubectl scale sts <name> -n <ns> --replicas=0
# wait for pod to terminate
kubectl patch pvc <name> -n <ns> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl annotate ks <name> -n <ns> reconcile.fluxcd.io/requestedAt=$(date +%s) --overwrite
# wait for new PVC
kubectl scale sts <name> -n <ns> --replicas=1
```
