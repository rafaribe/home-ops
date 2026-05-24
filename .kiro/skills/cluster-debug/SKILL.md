---
name: cluster-debug
description: Systematically investigate cluster issues starting from events, following the Flux pipeline down to pod logs
argument-hint: "[namespace/app or issue description] - Optional focus area"
---

# Cluster Debug Protocol

**MISSION**: Investigate cluster state using read-only operations, identify root causes, and propose GitOps-based fixes.

**SCOPE**: $ARGUMENTS

*If no arguments provided, perform a full cluster health check.*

## Investigation Order

1. **Events first** — always start here
2. **Flux pipeline** — KS → HR → Pod
3. **Logs** — container logs for the failing resource
4. **Storage** — PVC/PV issues if pod is pending
5. **Secrets** — ExternalSecret sync failures

## Step 1: Events

```bash
kubectl get events -A --sort-by='.lastTimestamp' | grep -v Normal | tail -30
```

## Step 2: Flux Status

```bash
flux get ks -A | grep -v "True"
flux get hr -A | grep -v "True"
```

For a specific app:
```bash
flux logs --kind=HelmRelease --namespace=<ns> --name=<app> --since=1h
```

## Step 3: Pod Status

```bash
kubectl get pods -n <ns> -o wide
kubectl describe pod -n <ns> <pod>
kubectl logs -n <ns> <pod> --previous   # if crashlooping
kubectl logs -n <ns> <pod> -f           # live
```

## Step 4: Force Reconcile

```bash
flux reconcile kustomization flux-system --with-source
flux reconcile hr <name> -n <namespace> --force
```

## Step 5: Validate Manifests

```bash
kustomize build kubernetes/apps/<namespace>/<app>/app
```

## Common Patterns

### CrashLoopBackOff
- Check `kubectl logs --previous` for the actual error
- Check `readOnlyRootFilesystem: true` — app may need a writable path in tmpfs
- Check security context UID matches image expectations

### Pending Pod
- `kubectl describe pod` → Events section
- PVC not found → check `existingClaim` name matches actual PVC
- Node affinity → openebs-hostpath PVCs are node-local
- GPU CDI error → Intel device plugin `bypathMode` issue

### HelmRelease Timeout
- Usually means pod didn't become Ready within timeout
- Check probe paths — wrong path causes readiness to never pass
- RWO PVC + RollingUpdate → add `strategy: Recreate`

### ExternalSecret Not Syncing
```bash
kubectl get externalsecret -n <ns> <name> -o jsonpath='{.status.conditions}'
kubectl get secret -n <ns> <name>
```

## Rules

- **Never** `kubectl apply/patch/delete` for persistent changes — edit Git source
- **Never** unsuspend a `disable-<app>` Flux KS without explicit instruction
- Present findings with evidence before proposing fixes
- All fixes go through Git → commit → push → reconcile
