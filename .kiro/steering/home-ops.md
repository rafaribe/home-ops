# home-ops Repository Knowledge

## What this repository is

A personal home lab Kubernetes cluster managed with Flux GitOps. All cluster state is declared in this repository and reconciled by Flux.

## Cluster nodes

- `srv-01` through `srv-07`: bare-metal servers running Talos Linux
- `tpi-1` through `tpi-4`: Raspberry Pi CM4 nodes running Talos Linux
- Control plane: `srv-02`, `srv-03`, `srv-07`
- Workers: `srv-01`, `srv-04`, `srv-05`, `srv-06`, `tpi-1` through `tpi-4`
- Talos Linux is immutable — there is no SSH access; node-level operations use `talosctl`

## Storage

- Rook-Ceph provides block, filesystem, and object storage
- OSD nodes: `srv-02`, `srv-03`, `srv-04`, `srv-06`, `srv-07`
- tpi nodes run Ceph mgr, mon, rgw, and CSI components but have no OSDs
- `disruptionManagement.managePodBudgets: true` is set on the CephCluster, which creates per-host OSD PDBs with `maxUnavailable: 0`

## Kubernetes apps

- All apps are deployed as Flux HelmReleases
- The primary app chart is `app-template` from bjw-s (`bjw-s/app-template`)
- App namespaces include: `downloads`, `media`, `services`, `home`, `database`, `observability`, `security`, `network`, `storage`, `games`, `ai`
- Databases are managed by CloudNative-PG (CNPG) in the `database` namespace
- Backup is handled by VolSync

## Tooling

- GitOps: Flux
- Node operations: `talosctl`
- Flux reconciliation: `flux` CLI
- Task runner: `task` (Taskfile.yml at repo root)
- Secrets: SOPS-encrypted, managed via External Secrets Operator

## Debugging Cheat Sheet

```bash
# Flux status
flux get ks -A                    # All Kustomizations
flux get hr -A                    # All HelmReleases
flux logs --kind=HelmRelease --namespace=<ns> --name=<app>

# Pod issues
kubectl -n <ns> get pods -o wide
kubectl -n <ns> describe pod <pod>
kubectl -n <ns> logs <pod> -f
kubectl -n <ns> get events --sort-by='.metadata.creationTimestamp'

# Force reconciliation
task reconcile
flux reconcile kustomization flux-system --with-source
flux reconcile hr <name> -n <namespace> --force

# Validate manifests
kustomize build kubernetes/apps/<namespace>/<app>/app
```
