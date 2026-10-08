---
name: descheduler
description: >
  Debug and configure the Kubernetes descheduler in this cluster. Covers
  Multi-Attach errors from PVC pod eviction, Kopiur mover duplicate-run
  noise, and descheduler policy tuning.
---

# Descheduler — Findings & Runbook

Config lives at: `kubernetes/apps/kube-system/descheduler/app/helmrelease.yaml`

The descheduler runs as a `Deployment` in `kube-system`. It uses `LowNodeUtilization`
to evict pods from hot nodes onto cooler ones and `RemoveFailedPods` / topology
plugins for correctness.

---

## Known Issue: Multi-Attach Errors from PVC Pod Eviction

### Symptoms

Cluster-wide `FailedAttachVolume` events firing in bursts across many namespaces:

```
Warning  FailedAttachVolume  pod/services/mealie-xxx
Multi-Attach error for volume "pvc-..." Volume is already exclusively
attached to one node and can't be attached to another
```

Affects any app using RWO (`ReadWriteOnce`) Ceph RBD block volumes
(`storageClassName: ceph-block`). Observed on: `actual`, `atuin`, `komga`,
`audiobookshelf`, `databasus`, `open-webui`, `alertmanager`, `slink`, `mealie`, etc.

### Root Cause

1. `LowNodeUtilization` identifies a hot node and evicts a pod to rebalance.
2. The pod has an RWO PVC (`ceph-block`). Its `VolumeAttachment` object on the old
   node is not immediately released — Ceph RBD kernel maps and kubelet bind-mounts
   persist for 30–90 seconds after pod termination.
3. Kubernetes reschedules the pod onto a **different node**.
4. The CSI provisioner tries to attach the volume on the new node but it is still
   exclusively attached to the old node → `Multi-Attach error`.
5. The pod stays in `ContainerCreating` until the old `VolumeAttachment` is GC'd.

### Fix

Add `ignorePvcPods: true` to `DefaultEvictor` in the HelmRelease:

```yaml
- name: DefaultEvictor
  args:
    evictFailedBarePods: true
    evictLocalStoragePods: true
    evictSystemCriticalPods: true
    ignorePvcPods: true          # prevents eviction of any pod with a PVC
```

This was applied on **2026-10-08** and is now live.

`ignorePvcPods: true` is the descheduler's built-in gate: it makes **all** eviction
plugins skip pods that have any `PersistentVolumeClaim`. Stateless pods without PVCs
remain eligible for rebalancing as before.

### Why Not Per-Pod Annotations?

`descheduler.alpha.kubernetes.io/evict: "false"` on individual pods would require
touching every HelmRelease that uses an RWO PVC — dozens of apps, and will drift as
new apps are added. `ignorePvcPods: true` is a single-line fix at the descheduler
level with the correct semantics for this cluster.

---

## Second Category: Kopiur Mover Duplicates (Benign, No Action)

Also appears as Multi-Attach events but is completely harmless:

```
Warning  FailedAttachVolume  pod/services/mealie-20261008020100-ccr7x
Multi-Attach error ... Volume is already used by pod(s) mealie-20261008020100-ghp6l
```

These are **Kopiur backup mover pods**. The `H * * * *` jitter schedule occasionally
fires a second job before the first mover finishes. Kopiur's `concurrencyPolicy: Forbid`
blocks the duplicate — it just can't mount the PVC held by the active mover and exits.
The working mover continues normally.

**Distinguishing marker**: pod name contains a 14-digit timestamp —
`appname-YYYYMMDDHHMMSS-xxxxx`. Regular deployment pods look like `app-replicaset-xxxxx`.

---

## Descheduler Throttling

The descheduler continuously polls `metrics.k8s.io` for every node on a tight loop.
Observed 100–155 ms client-side throttle delays per node per cycle. On an 11-node cluster
this generates noticeable metrics-server load.

Watch for:
```
I ... "Waited before sending request" delay="150ms" reason="client-side throttling"
E ... "Error fetching metrics" err="nodemetrics ... not found" node="tpi-3"
```

The `tpi-3` not-found errors are transient (Raspberry Pi CM4 nodes report metrics slower).
Not actionable unless persistent — in that case check `metrics-server` health in
`kube-system`.

---

## Quick Diagnosis

```bash
# Are the Multi-Attach errors from descheduler evictions or Kopiur movers?
kubectl get events -A --field-selector=reason=FailedAttachVolume \
  --sort-by='.lastTimestamp' | tail -20

# Check if descheduler is actively evicting
kubectl logs -n kube-system -l app.kubernetes.io/name=descheduler \
  --since=1h | grep -i evict | head -20

# Verify ignorePvcPods is live in the configmap
kubectl get configmap -n kube-system descheduler \
  -o jsonpath='{.data.policy\.yaml}' | grep ignorePvcPods

# Confirm evictions per cycle
kubectl logs -n kube-system -l app.kubernetes.io/name=descheduler --tail=10 \
  | grep evictedPods
```

## After Changing the Config

```bash
flux reconcile hr descheduler -n kube-system --force

# Pod should restart; last cycle should show evictedPods=0 for PVC workloads
kubectl logs -n kube-system -l app.kubernetes.io/name=descheduler --tail=10 \
  | grep -E "evictedPods|Total number"
```
