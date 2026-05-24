---
name: upgrade-app
description: Safely upgrade an app's image or chart version, checking for breaking changes and updating the HelmRelease
argument-hint: "[namespace/app] [new-version] - e.g. media/jellyfin 10.11.0"
---

# App Upgrade Protocol

**MISSION**: Safely upgrade an application's image or Helm chart version with minimal disruption.

**SCOPE**: $ARGUMENTS

*Provide `namespace/app` and optionally the target version. If no version given, find the latest.*

## Step 1: Identify Current Version

```bash
# Read the current helmrelease
cat kubernetes/apps/<namespace>/<app>/app/helmrelease.yaml | grep -A3 "image:\|tag:\|chartRef"
```

## Step 2: Find Latest Version

For container images:
```bash
# Check GitHub releases or container registry
crane ls ghcr.io/<org>/<image> 2>/dev/null | grep -E "^v?[0-9]+\.[0-9]+" | sort -V | tail -5

# Get digest for pinning
crane digest ghcr.io/<org>/<image>:<tag>
```

For Helm charts (OCIRepository):
```bash
crane ls ghcr.io/bjw-s-labs/helm/app-template | sort -V | tail -5
```

## Step 3: Check for Breaking Changes

Before upgrading, check the changelog:
- GitHub releases page for the project
- Look for migration guides, database schema changes, config format changes
- Check if `readOnlyRootFilesystem` compatibility changed
- Check if default ports changed

## Step 4: Update the HelmRelease

Update `tag:` with both version AND digest:
```yaml
image:
  repository: ghcr.io/example/app
  tag: 1.2.3@sha256:abc123...
```

For app-template chart version (OCIRepository):
```yaml
# In ocirepository.yaml
ref:
  tag: 5.0.1
```

## Step 5: Handle Common Upgrade Issues

### Database migrations
If the app runs DB migrations on startup, ensure:
- `strategy: Recreate` (not RollingUpdate) so old pod stops before new one starts
- Adequate startup probe `failureThreshold` (30+ for slow migrations)

### Config format changes
- Check if any env vars were renamed or removed
- Check if persistence paths changed

### Breaking probe paths
- Verify `/health`, `/healthz`, or `/api/health` still works in new version
- Check the app's changelog or Dockerfile for health check endpoint

## Step 6: Commit and Reconcile

```bash
git add kubernetes/apps/<namespace>/<app>/app/helmrelease.yaml
git commit -m "chore(<app>): upgrade to <version>"
git push
flux reconcile hr <app> -n <namespace> --force
```

## Step 7: Verify

```bash
kubectl get pods -n <namespace> -l app.kubernetes.io/name=<app>
kubectl logs -n <namespace> -l app.kubernetes.io/name=<app> --tail=20
flux get hr <app> -n <namespace>
```

## Cluster-Specific Notes

- **app-template** current version: `5.0.1` (shared OCIRepository in `kubernetes/components/repos/app-template/`)
- **Per-app OCIRepositories** also need updating (e.g. `kubernetes/apps/media/jellyfin/app/ocirepository.yaml`)
- **Intel GPU** (`gpu.intel.com/i915`) is currently broken due to CDI injection issue — do not add GPU requests
- **Renovate** handles most upgrades automatically via PRs — check open PRs before manual upgrades
- Always pin with **tag + SHA256 digest**, never tag-only
