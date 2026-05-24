---
name: lint
description: Analyze GitOps repo structure for ordering issues, broken references, missing dependencies, and anti-patterns
argument-hint: "[namespace or app] - Optional scope, defaults to full scan"
---

# GitOps Lint Protocol

**MISSION**: Scan the repository for structural issues, broken references, missing Flux dependencies, and anti-patterns.

**SCOPE**: $ARGUMENTS

*If no arguments provided, scan all of `kubernetes/apps/`.*

## What to Check

### 1. Broken kustomization references
Every file listed in `kustomization.yaml` must exist:
```bash
# Find resources listed but missing
for f in kubernetes/apps/**/**/kustomization.yaml; do
  dir=$(dirname $f)
  yq '.resources[]' $f | while read r; do
    [ ! -f "$dir/$r" ] && echo "MISSING: $dir/$r (referenced in $f)"
  done
done
```

### 2. Missing schema headers
Every YAML file must start with `# yaml-language-server: $schema=...`:
```bash
find kubernetes/ -name "*.yaml" | xargs grep -rL "yaml-language-server" | grep -v kustomization
```

### 3. Anti-patterns
Check for violations of repo conventions:

| Anti-pattern | Check |
|---|---|
| `kind: Ingress` | Should use `HTTPRoute` |
| `chart.spec.sourceRef` inline | Should use `chartRef` + `OCIRepository` |
| `image.tag: latest` | Must pin with digest |
| Missing `securityContext` | All containers need hardening |
| `readOnlyRootFilesystem: false` without justification | Flag for review |
| `metadata.namespace` in app resources | Breaks `targetNamespace` inheritance |
| `strategy: RollingUpdate` with RWO PVC | Must use `Recreate` |
| `postBuild.substituteFrom` for secrets | Timing race with ExternalSecrets |

```bash
# Check for Ingress resources
grep -r "kind: Ingress" kubernetes/apps/ --include="*.yaml" -l

# Check for inline chart sourceRef
grep -r "chart.spec.sourceRef" kubernetes/apps/ --include="*.yaml" -l

# Check for latest tags
grep -r "tag: latest" kubernetes/apps/ --include="*.yaml" -l

# Check for RollingUpdate with existingClaim
grep -rB5 "existingClaim" kubernetes/apps/ --include="*.yaml" | grep -B5 "RollingUpdate"
```

### 4. Flux dependency ordering
Apps that use ExternalSecrets must depend on `external-secrets-stores`:
```bash
# Find HRs with ExternalSecret but missing dependsOn
for ks in kubernetes/apps/**/ks.yaml; do
  app_dir=$(dirname $ks)/app
  if ls $app_dir/externalsecret.yaml 2>/dev/null; then
    if ! grep -q "external-secrets-stores" $ks; then
      echo "MISSING dependsOn: $ks"
    fi
  fi
done
```

Apps that use CNPG databases should depend on `cloudnative-pg`:
```bash
grep -rl "postgres-init\|INIT_POSTGRES" kubernetes/apps/ --include="*.yaml" | while read f; do
  ks=$(find $(dirname $(dirname $f)) -name "ks.yaml" | head -1)
  grep -q "cloudnative-pg" $ks 2>/dev/null || echo "MISSING CNPG dep: $ks"
done
```

### 5. Orphaned resources
Files in `app/` not referenced in `kustomization.yaml`:
```bash
for dir in kubernetes/apps/*/*/app; do
  ks="$dir/kustomization.yaml"
  [ ! -f "$ks" ] && echo "MISSING kustomization.yaml: $dir" && continue
  for f in $dir/*.yaml; do
    base=$(basename $f)
    [ "$base" = "kustomization.yaml" ] && continue
    grep -q "$base" $ks || echo "ORPHANED: $f"
  done
done
```

### 6. Namespace kustomization coverage
Every app directory must be referenced in its namespace `kustomization.yaml`:
```bash
for ns_ks in kubernetes/apps/*/kustomization.yaml; do
  ns_dir=$(dirname $ns_ks)
  for app_ks in $ns_dir/*/ks.yaml; do
    app=$(basename $(dirname $app_ks))
    grep -q "$app" $ns_ks || echo "NOT IN NAMESPACE KS: $app_ks"
  done
done
```

## Output Format

Report issues grouped by severity:

### 🚨 CRITICAL — Will break reconciliation
- Missing files referenced in kustomization.yaml
- Missing namespace kustomization entries

### ⚠️ WARNING — Anti-patterns or missing best practices
- Missing schema headers
- Anti-pattern violations
- Missing Flux dependencies

### ℹ️ INFO — Suggestions
- Orphaned files
- Inconsistent naming

## Rules

- Read files before making claims
- Only report actual issues found, not hypothetical ones
- Provide the exact file path and line for each issue
- Suggest the minimal fix for each issue
