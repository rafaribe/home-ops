---
name: add-app
description: Scaffold a new app-template application for this home-ops repository
---

# Add New Application

This skill scaffolds a new application for this repository's Flux layout.

## Repository-specific assumptions

- Flux app manifests are named `kubernetes/apps/<namespace>/<app>.yaml`
- Namespace and shared repositories come from `kubernetes/components/`
- `app-template` is referenced as `spec.chartRef.name: app-template`
- Secrets use `external-secrets` with the `akeyless` `ClusterSecretStore`

## Workflow

### Step 1: Collect application details

Use the `question` tool to gather:

1. App name
2. Namespace/category, such as `downloads`, `media`, or `services`
3. Image repository
4. Image tag or digest
5. Primary service port
6. Whether the app needs `ExternalSecret`
7. Whether the app needs persistence
8. Whether the app needs ingress or gateway route
9. Any Flux `dependsOn` entries for the cluster overlay manifest

Always ask for confirmation before writing files.

### Step 2: Search kubesearch.dev for reference configs

Before generating files, search kubesearch.dev to find real-world HelmRelease examples:

1. Visit `https://kubesearch.dev/` and search for the app name
2. If results exist, click through to find HelmRelease YAML files from other homelabs
3. Use these as reference for values structure, env vars, probes, and persistence patterns
4. Convert GitHub blob URLs to raw URLs to fetch full file contents if needed

Example URL pattern: `https://kubesearch.dev/hr/<registry-path>` (e.g., `https://kubesearch.dev/hr/ghcr.io-johanohly-airtrail`)

### Step 3: Inspect neighboring apps

Before generating files:

1. Read 1-2 existing apps in the same namespace.
2. Prefer matching the local patterns for probes, persistence, routes, and secret templates.
3. If the namespace overlay does not exist for a requested cluster, ask the user how they want to proceed.

### Step 4: Create the base app directory

Create:

`kubernetes/apps/<namespace>/<app>/`

At minimum, create:

- `kustomization.yaml`
- `helmrelease.yaml`

Optionally create:

- `externalsecret.yaml`
- other app-specific manifests such as `prometheusrule.yaml`, `configmap.yaml`, or `pvc.yaml`
- `ocirepository.yaml` if there is no namespace specific app-template

### Step 5: Generate base app files

#### `kubernetes/apps/<namespace>/<app>/kustomization.yaml`

```yaml
---
# yaml-language-server: $schema=https://json.schemastore.org/kustomization
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ./helmrelease.yaml
```

Add `./externalsecret.yaml` only if secrets are needed. Add other resource files only when required.

#### `kubernetes/apps/base/<namespace>/<app>/helmrelease.yaml`

```yaml
---
# yaml-language-server: $schema=https://raw.githubusercontent.com/bjw-s-labs/helm-charts/main/charts/other/app-template/schemas/helmrelease-helm-v2.schema.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app>
spec:
  chartRef:
    kind: OCIRepository
    name: app-template
  dependsOn: []
  interval: 15m
  values:
    controllers:
      <app>:
        containers:
          app:
            image:
              repository: <image-repository>
              tag: <image-tag-or-digest>
            probes:
              liveness:
                enabled: true
              readiness:
                enabled: true
            resources:
              requests:
                cpu: 10m
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                  - ALL
              readOnlyRootFilesystem: true
    defaultPodOptions:
      securityContext:
        fsGroup: 1000
        fsGroupChangePolicy: OnRootMismatch
        runAsGroup: 1000
        runAsNonRoot: true
        runAsUser: 1000
    service:
      app:
        ports:
          http:
            port: <port>
```

Adjust the template to match local patterns in the same namespace. Add `route`, `persistence`, `env`, `envFrom`, or extra manifests only when needed.

#### `kubernetes/apps/base/<namespace>/<app>/externalsecret.yaml`

```yaml
---
# yaml-language-server: $schema=https://kube-schemas.pages.dev/external-secrets.io/externalsecret_v1.json
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: &app <app> 
spec:
  refreshInterval: 5m
  secretStoreRef:
    kind: ClusterSecretStore
    name: akeyless-secret-store
  target:
    name: *app
    template:
      engineVersion: v2
      data:
        MYKEY: "{{ .MY_KEY_IN_AKEYLESS_JSON }}"
  dataFrom:
    - extract:
        key: <app>
```

If the app needs templated secret data, mirror patterns from similar existing apps instead of forcing a generic template. Always reference the keys explicitely in the `data` section if possible.

### Step 5: Generate app flux kustomization ks

For each selected cluster, create:

`kubernetes/apps/<namespace>/<app>/ks.yaml`

Template:

```yaml
---
# yaml-language-server: $schema=https://kube-schemas.pages.dev/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app <app>
spec:
  interval: 1h
  path: ./kubernetes/apps/<namespace>/<app>
  postBuild:
    substitute:
      APP: *app
      CLUSTER: ${CLUSTER}
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system
  wait: false
```

Only include `components` or `dependsOn` when the app needs them. Follow nearby overlay manifests in the same namespace for exact patterns.

### Step 6: Update overlay kustomizations

For each selected cluster, update:

`kubernetes/apps/<cluster>/<namespace>/kustomization.yaml`

Add:

```yaml
resources:
  - ./<app>.yaml
```

Keep the resource list alphabetized.

### Step 7: Verify

Verify that:

1. The base app directory contains the expected files.
2. Every selected cluster has an overlay app manifest.
3. Every selected cluster overlay `kustomization.yaml` references the new app.
4. The HelmRelease uses the shared `app-template` repository name rather than a per-app `OCIRepository`.
5. No plain-text secrets were introduced.

## Notes

- Do not create a per-app `ocirepository.yaml` for `app-template` apps in this repository.
- Prefer minimal scaffolding that matches existing apps in the same namespace.
- If the workload is not a good fit for `app-template`, stop and ask the user before continuing.
