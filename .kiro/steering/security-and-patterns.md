# Security, Hardening & Anti-Patterns

## Container Security — Always Apply

Every container must include these security settings unless the image explicitly requires otherwise:

```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities: { drop: ["ALL"] }
```

Every pod must include:

```yaml
defaultPodOptions:
  securityContext:
    runAsNonRoot: true
    runAsUser: 568       # or image-appropriate UID
    runAsGroup: 568
    seccompProfile: { type: RuntimeDefault }
```

## Image Pinning

Always pin images with both tag AND digest:

```yaml
image:
  repository: ghcr.io/example/app
  tag: 1.2.3@sha256:abc123...
```

Never use `latest` or mutable tags.

## GitOps Enforcement

- **NEVER run `kubectl apply/create/patch/delete`** for persistent changes — all changes go through Git
- **NEVER commit unencrypted secrets** — use ExternalSecrets or SOPS
- Treat local file edits as the source of truth; Flux reconciles them to the cluster

## Anti-Patterns — Do NOT Do These

1. **Do NOT use `Ingress` resources** — use `HTTPRoute` with Envoy Gateway
2. **Do NOT use inline `chart.spec.sourceRef`** in HelmReleases — use `chartRef` with `OCIRepository`
3. **Do NOT pin images by tag only** — always include SHA256 digest
4. **Do NOT skip security context** — harden all containers
5. **Do NOT skip `# yaml-language-server: $schema=...`** headers on YAML files
6. **Do NOT use `latest` tags** for any container image
7. **Do NOT commit plaintext secrets** — use ExternalSecrets (akeyless) or SOPS
8. **Do NOT use `postBuild.substituteFrom` for secrets** — timing race with ExternalSecrets
9. **Do NOT use `git add .` or `git add -A`** — stage specific files only
10. **Do NOT modify cluster directly** to make lasting changes — always edit Git source
11. **Do NOT add `metadata.namespace`** in app resources when `targetNamespace` is set in ks.yaml — it breaks inheritance
12. **Do NOT use RollingUpdate strategy with RWO PVCs** — use `strategy: Recreate` to avoid Multi-Attach errors

## Reloader Annotation

Any controller that consumes ConfigMaps or Secrets must have:

```yaml
annotations:
  reloader.stakater.com/auto: "true"
```

## Schema Comments

Every YAML file must start with:

```yaml
---
# yaml-language-server: $schema=<appropriate-schema-url>
```

Schema sources:
- Flux resources: `https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/`
- HelmRelease (app-template): `https://raw.githubusercontent.com/bjw-s/helm-charts/main/charts/other/app-template/schemas/helmrelease-helm-v2.schema.json`
- Kustomize: `https://json.schemastore.org/kustomization`
- CRDs: `https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/`

## Working Rules

- Inspect the target area before editing; do not assume
- Keep changes minimal and surgical — touch only what you must
- Match existing patterns and style in the codebase
- Do not "improve" adjacent code, comments, or formatting unless asked
- Every changed line should trace directly to the user's request
- Stage commits with explicit file paths, never `git add -A`

## Commit Conventions

- Use semantic/conventional commits: `type(scope): message`
- Types: `feat`, `fix`, `chore`, `docs`, `refactor`
- Scope is usually the app name or category
- Keep subject line concise and imperative
