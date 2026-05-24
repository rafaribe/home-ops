---
name: volsync-restore
description: Restore a VolSync-backed PVC from a previous snapshot for any app in this cluster
argument-hint: "[namespace/app] [snapshot-index] - e.g. services/karakeep 1"
---

# VolSync Restore Protocol

**MISSION**: Restore a VolSync-backed application PVC from a previous snapshot.

**SCOPE**: $ARGUMENTS

*Provide `namespace/app` and optionally a snapshot index (0 = latest, 1 = previous, etc.)*

## Prerequisites

- App must have a `ReplicationSource` in its namespace
- VolSync must be running (`flux get hr volsync -n storage`)
- App must be suspended before restore to release the PVC

## Step 1: Identify Available Snapshots

```bash
# List ReplicationSources
kubectl get replicationsource -n <namespace>

# Check last sync time and status
kubectl get replicationsource <app> -n <namespace> -o yaml | grep -A10 "lastSyncTime\|lastSyncDuration\|latestMoverPod"
```

## Step 2: Suspend the App

```bash
flux suspend ks <app> -n <namespace>
flux suspend hr <app> -n <namespace>

# Scale down to release RWO PVC
kubectl scale deployment -n <namespace> <app> --replicas=0
# Wait for pod termination
kubectl wait pod -n <namespace> -l app.kubernetes.io/name=<app> --for=delete --timeout=2m
```

## Step 3: Create ReplicationDestination

```bash
# Get source PVC details
SOURCE_PVC=$(kubectl get replicationsource <app> -n <namespace> -o jsonpath='{.spec.sourcePVC}')
STORAGE_CLASS=$(kubectl get pvc $SOURCE_PVC -n <namespace> -o jsonpath='{.spec.storageClassName}')
CAPACITY=$(kubectl get pvc $SOURCE_PVC -n <namespace> -o jsonpath='{.spec.resources.requests.storage}')
ACCESS_MODE=$(kubectl get pvc $SOURCE_PVC -n <namespace> -o jsonpath='{.spec.accessModes[0]}')
```

Apply a ReplicationDestination (replace `<previous>` with snapshot index, 0=latest):

```yaml
apiVersion: volsync.backube/v1alpha1
kind: ReplicationDestination
metadata:
  name: <app>-restore
  namespace: <namespace>
spec:
  trigger:
    manual: restore-$(date +%s)
  restic:
    repository: <app>-volsync-secret   # matches ReplicationSource secret
    destinationPVC: <app>              # target PVC name
    storageClassName: <storage-class>
    accessModes: [<access-mode>]
    copyMethod: Direct
    previous: <snapshot-index>         # 0=latest, 1=previous, etc.
    moverSecurityContext:
      runAsUser: 568
      runAsGroup: 568
      fsGroup: 568
```

## Step 4: Wait for Restore

```bash
kubectl wait job -n <namespace> volsync-dst-<app>-restore --for=condition=complete --timeout=60m
kubectl logs -n <namespace> -l app.kubernetes.io/component=mover,app.kubernetes.io/name=<app>-restore
```

## Step 5: Resume the App

```bash
kubectl delete replicationdestination -n <namespace> <app>-restore
flux resume ks <app> -n <namespace>
flux resume hr <app> -n <namespace>
flux reconcile hr <app> -n <namespace> --force
kubectl wait pod -n <namespace> -l app.kubernetes.io/name=<app> --for=condition=ready --timeout=5m
```

## Step 6: Trigger a Fresh Snapshot

```bash
kubectl patch replicationsource <app> -n <namespace> --type merge \
  -p '{"spec":{"trigger":{"manual":"post-restore-'$(date +%s)'"}}}'
```

## Cluster-Specific Notes

- **Secret store**: akeyless (`ClusterSecretStore: akeyless-secret-store`)
- **Default storage**: `ceph-block` (RWO)
- **VolSync namespace**: `storage`
- **Backup destination**: configured per-app via ExternalSecret
- **UID/GID**: default `568` unless app specifies otherwise (check `defaultPodOptions.securityContext`)
