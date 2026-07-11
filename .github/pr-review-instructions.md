# Home-ops PR review conventions

This file is the `system_prompt_file` for the AI PR Review workflow, used with
`system_prompt_mode: append`: the action keeps its bundled default system prompt
and appends this file as a repo-specific addendum.

## Repository context

This is a home lab Kubernetes cluster managed with Flux GitOps. All cluster state
is declared in this repository and reconciled by Flux. Nodes run Talos Linux
(immutable, no SSH). The primary app chart is `app-template` from bjw-s.

## Conventions to honour without flagging

The following patterns are intentional in this repository. Do not surface them as
concerns, warnings, or "for awareness" notes:

### Namespace handling

- **`metadata.namespace` is intentionally absent on `HelmRelease` and `Kustomization` resources.**
  The namespace is injected at build time by kustomize's `namespace:` directive in the
  per-app `kustomization.yaml`, or via `spec.targetNamespace` in `ks.yaml`.
  Do not flag the absence of `metadata.namespace` on these resources.

### Image pinning

- Container images are pinned with both tag AND `@sha256:` digest (e.g., `tag: 1.2.3@sha256:abc...`).
- **OCI artifacts** (pulled via `OCIRepository` for Helm charts) are pinned by tag/version only.
  Do not flag the absence of `@sha256:` on OCI artifact references — they don't support
  SHA-tag references the same way container images do.

### Networking

- This repo uses **Gateway API `HTTPRoute`** resources, NOT `Ingress`.
  Do not suggest Ingress or flag missing Ingress resources.
- Two gateways: `envoy-internal` (LAN) and `envoy-external` (public via cloudflared).

### HelmRelease pattern

- HelmReleases use `chartRef` with a per-app `OCIRepository` — never inline `chart.spec.sourceRef`.
- The chart source is `oci://ghcr.io/bjw-s-labs/helm/app-template`.

### Secrets

- Secrets use External Secrets Operator with `ClusterSecretStore: akeyless-secret-store`.
- SOPS + Age is used only for bootstrap secrets.
- Do not flag ExternalSecret CRs as "missing secrets".

### Security context

- All containers should have `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`,
  `capabilities: { drop: ["ALL"] }`.
- Pod-level: `runAsNonRoot: true`, `seccompProfile: { type: RuntimeDefault }`.
- Flag missing security context as a finding.

### YAML formatting

- All YAML files start with `---` and include `# yaml-language-server: $schema=...` header.
- Use the Flux schema source for Flux CRDs, bjw-s schema for HelmReleases.

## What to look for

- Missing or incorrect security context on containers
- Images pinned without `@sha256:` digest (container images only, not OCI repos)
- Use of `Ingress` instead of `HTTPRoute`
- Inline `chart.spec.sourceRef` instead of `chartRef` with `OCIRepository`
- Missing `reloader.stakater.com/auto: "true"` on controllers that consume ConfigMaps/Secrets
- `strategy: RollingUpdate` with RWO PVCs (should use `Recreate`)
- Plaintext secrets committed to the repository
- Changes that bypass GitOps (e.g., suggesting `kubectl apply`)

## Compact Renovate digest-only reviews

For Renovate digest-only container image updates where the repository and tag are
unchanged and the diff only changes `@sha256:` values, keep `review_markdown` compact.
Prefer a short recommendation and changed files summary. Do not include separate
Standards Compliance or Tool Findings sections unless they contain an actual blocker.
