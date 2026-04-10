# Rook-Ceph Resource Constraint Issues

**Date:** 2026-04-10  
**Status:** Pending resolution

## Summary

Two pods are in `Pending` state due to insufficient CPU resources on nodes that are fully allocated by rook-ceph workloads. These were identified during a cluster health audit but left unresolved per the constraint of not modifying rook-ceph resources.

---

## Issue 1: `rook-ceph-exporter-srv-02` — Pending (Insufficient CPU)

**Pod:** `rook-ceph/rook-ceph-exporter-srv-02-54864cd448-7rsmr`  
**Node target:** `srv-02` (node affinity selector: `kubernetes.io/hostname=srv-02`)  
**Error:** `0/10 nodes are available: 1 Insufficient cpu, 9 node(s) didn't match Pod's node affinity/selector`

### Root Cause

`srv-02` is a control-plane node with 3950m allocatable CPU. It is at **100% CPU requests** due to rook-ceph workloads:

| Pod | CPU Request |
|-----|-------------|
| `rook-ceph-mon-c` | 1100m (27%) |
| `rook-ceph-osd-0` | 1100m (27%) |
| `rook-ceph-rgw-ceph-objectstore-a` | 200m (5%) |
| `rook-ceph.cephfs.csi.ceph.com-nodeplugin` | 300m (7%) |
| `rook-ceph.rbd.csi.ceph.com-nodeplugin` | 300m (7%) |
| `rook-ceph-crashcollector-srv-02` | 100m (2%) |
| Other system pods | ~750m |
| **Total** | **3950m (100%)** |

The `rook-ceph-exporter` requests 50m CPU but there is no room.

### Steps to Resolve

1. **Option A — Reduce rook-ceph-exporter CPU request:**  
   Edit the rook-ceph cluster configuration to lower the exporter's CPU request to `10m` or `0` (it uses ~0.3m actual CPU).  
   In the rook-ceph CephCluster CR, look for `resources.mgr` or exporter-specific resource overrides.

2. **Option B — Reduce rook-ceph OSD/MON CPU requests on srv-02:**  
   In the CephCluster CR, set per-daemon resource overrides to reduce the CPU requests for the OSD and MON on srv-02. These are significantly over-requested (actual usage is much lower than 1100m).

3. **Option C — Move a non-rook workload off srv-02:**  
   Reschedule one of the non-rook pods (e.g., `prowlarr`, `flaresolverr`, `cyberchef`) to another node to free up CPU request headroom.

---

## Issue 2: `rook-ceph-crashcollector-srv-06` — Pending (Insufficient Memory)

**Pod:** `rook-ceph/rook-ceph-crashcollector-srv-06-5d58765c98-zl6q4`  
**Node target:** `srv-06` (node affinity selector: `kubernetes.io/hostname=srv-06`)  
**Error:** `0/10 nodes are available: 1 Insufficient memory, 9 node(s) didn't match Pod's node affinity/selector`

### Root Cause

`srv-06` has 13490248Ki allocatable memory. The crashcollector requests 60Mi but the node is at or near memory request capacity due to other workloads.

### Steps to Resolve

1. **Option A — Reduce crashcollector memory request:**  
   In the CephCluster CR, set `resources.crashcollector.requests.memory` to a lower value (e.g., `32Mi`). The crashcollector is a lightweight daemon.

2. **Option B — Reduce memory requests of other pods on srv-06:**  
   Review pods on srv-06 and reduce over-provisioned memory requests.

3. **Option C — Check for memory leaks:**  
   Run `kubectl top nodes` and `kubectl top pods -n <namespace> --sort-by=memory` to identify if any pod is consuming excessive memory on srv-06.

---

## Issue 3: `intel-gpu-exporter-8j6vm` — Pending (Insufficient CPU on srv-02)

**Pod:** `kube-system/intel-gpu-exporter-8j6vm`  
**Node target:** `srv-02` (DaemonSet with `nodeSelector: intel.feature.node.kubernetes.io/gpu=true`)  
**Error:** `0/10 nodes are available: 1 Insufficient cpu, 9 node(s) didn't satisfy plugin(s) [NodeAffinity]`

### Root Cause

This is a side effect of Issue 1. `srv-02` is the only Intel GPU node that doesn't have a running `intel-gpu-exporter` pod, and it's at 100% CPU requests due to rook-ceph.

### Steps to Resolve

Resolving Issue 1 (freeing CPU on srv-02) will allow this pod to schedule. Alternatively:

1. Reduce the `intel-gpu-exporter` CPU request from `50m` to `10m` in the HelmRelease at `kubernetes/apps/kube-system/intel-device-plugin/exporter/helmrelease.yaml`. The actual CPU usage is ~0.3-0.7m.

---

## Related Resources

- CephCluster CR: `rook-ceph/rook-ceph` (managed by Flux kustomization `rook-ceph/rook-ceph-cluster`)
- Node: `srv-02` (control-plane, Intel GPU node)
- Node: `srv-06` (worker node)
