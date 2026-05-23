# Repository Conventions & Operations

## Repository Structure

```text
home-ops/
├── kubernetes/          # Kubernetes configurations (Flux-managed)
│   ├── apps/            # Application configs organized by namespace
│   ├── components/      # Reusable Kustomize components
│   └── flux/            # Flux cluster definitions
├── bootstrap/           # Bootstrap templates (helmfile)
└── docs/                # Documentation
```

## Key Technologies

| Category      | Tool                         | Purpose                              |
|---------------|------------------------------|--------------------------------------|
| GitOps        | Flux (via flux-operator)     | Deploys configs from Git to k8s      |
| CI            | Renovate + GitHub Actions    | Dependency updates, automation       |
| Runners       | Actions Runner Controller    | Self-hosted GitHub Actions runners   |
| Networking    | Cilium (eBPF)                | CNI, LoadBalancer                    |
| Ingress       | Envoy Gateway                | L7 gateway / HTTPRoute               |
| Tunnel        | cloudflared                  | Public ingress without exposing WAN  |
| DNS           | external-dns                 | Cloudflare + Pi-hole split DNS       |
| AuthN/Z       | Authentik + GLAuth           | SSO/OIDC + LDAP                      |
| Secrets       | SOPS + External Secrets      | Secret management (akeyless backend) |
| Storage       | Rook/Ceph, OpenEBS, Democratic-CSI, Garage | Tiered storage       |
| Registry      | Spegel                       | Peer-to-peer container image cache   |
| Databases     | CloudNative-PG, Dragonfly    | Postgres clusters + Redis-compatible |
| Backup        | VolSync, Kopia               | PVC replication + backup             |
| Observability | kube-prometheus-stack, Victoria Logs, Grafana, Gatus | Metrics, logs, uptime |
| AI            | Ollama, Open WebUI           | Local LLM inference                  |
| Home Auto     | Home Assistant, Zigbee2MQTT  | Smart home                           |
| GPU           | Intel device plugin, NVIDIA device plugin | Hardware acceleration |
| Scheduling    | Descheduler, KEDA            | Pod rebalancing + event-driven scaling |
| Node mgmt    | Talos Linux + talosctl       | Immutable OS, no SSH                 |

## GitOps Flow

```text
Git push → Flux source sync → Kustomization → HelmRelease → k8s resources
```

Flux recursively searches `kubernetes/apps/` for `kustomization.yaml` files. Each must define a namespace and Flux kustomization (`ks.yaml`).

## Application Deployment Pattern

Every app follows this structure:

```text
kubernetes/apps/<namespace>/<app-name>/
├── ks.yaml                    # Flux Kustomization (entry point)
└── app/
    ├── kustomization.yaml     # Kustomize resource list
    ├── helmrelease.yaml       # HelmRelease (app-template chart)
    ├── ocirepository.yaml     # OCI chart source (per app)
    └── externalsecret.yaml    # ExternalSecret (optional)
```

### ks.yaml Pattern

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app <app-name>
spec:
  targetNamespace: <namespace>
  commonMetadata:
    labels:
      app.kubernetes.io/name: *app
  interval: 30m
  timeout: 5m
  path: "./kubernetes/apps/<namespace>/<app-name>/app"
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system
  wait: false
  dependsOn:
    - name: external-secrets-stores
      namespace: external-secrets
  postBuild:
    substitute:
      APP: *app
      GATUS_SUBDOMAIN: <app-name>
```

### HelmRelease Pattern

- Use `chartRef` with `OCIRepository` — never inline `chart.spec.sourceRef`
- Each app gets its own `OCIRepository` pointing to `oci://ghcr.io/bjw-s-labs/helm/app-template`
- Use `reloader.stakater.com/auto: "true"` annotation on controllers that consume ConfigMaps/Secrets

### Secrets Pattern

- ExternalSecrets use `ClusterSecretStore: akeyless-secret-store`
- Database credentials use `home-operations/postgres-init` init container
- SOPS + Age only for bootstrap secrets

### Networking Pattern

- **Do NOT use Ingress resources** — use Gateway API `HTTPRoute` via app-template `route`
- Two gateways: `envoy-internal` (LAN) and `envoy-external` (public via cloudflared)
- Both in namespace `network`, sectionName `https`

## Conventions

- Apps use `HelmRelease` via Flux, rarely raw manifests
- Secrets are managed via External Secrets Operator (akeyless backend)
- The primary app chart is `app-template` from bjw-s
- All YAML files start with `---` and include `# yaml-language-server: $schema=...`
- Task runner: `task` (Taskfile.yml at repo root)

### Flux suspend / disable workflow

Look for the `disable-<app>` / `Revert "disable-<app>"` commit pattern in `git log`. This means the user manually paused an app's reconciliation to break the GitOps loop temporarily.

**Do not** revert these, "fix" them, or unsuspend a Flux Kustomization without explicit instruction.

### Blast radius

A single PR should touch at most 50 files. Larger sweeps require explicit user approval.

## Common Operations

- **Add app**: Create in `kubernetes/apps/<namespace>/` with kustomization + HelmRelease
- **Update app**: Merge Renovate PR or manually edit and push
- **Troubleshoot**: Check `flux get all -n <namespace>`, `kubectl get events --sort-by=.lastTimestamp`
- **Reconcile**: `task reconcile` or `flux reconcile kustomization flux-system --with-source`

## Validation

```bash
task reconcile                    # Force Flux reconcile
flux get ks -A                    # Check all Kustomizations
flux get hr -A                    # Check all HelmReleases
kubectl get events -n <ns> --sort-by='.lastTimestamp'
```
