---
description: Specialized FluxCD troubleshooting workflow for GitOps issues
argument-hint: [component or issue] - Optional focus on specific Flux component or problem
---

# Flux Debug Protocol

**MISSION**: Systematically troubleshoot FluxCD components and GitOps reconciliation issues
in the k8s-homelab cluster using structured investigation patterns.

**SCOPE**: $ARGUMENTS

*If no arguments provided, perform comprehensive Flux health check.*

## Investigation Priority

1. **Flux Status Overview** - Get complete picture of Flux state
2. **Git Source Health** - Verify repository access and sync status
3. **Kustomization Pipeline** - Follow the reconciliation chain
4. **HelmRelease Issues** - Dive into Helm chart problems
5. **Secret Dependencies** - Check SOPS and ExternalSecrets integration
6. **Webhook & Automation** - Verify automatic reconciliation

## What I Will Do

**Immediate Flux Assessment:**

- Check all Flux sources, kustomizations, and helm releases
- Identify failed reconciliations and error patterns
- Analyze dependency chains and reconciliation order
- Verify Git repository connectivity and access

**Deep Dive Investigation:**

- Examine Flux controller logs for specific errors
- Validate SOPS encryption and secret access
- Check webhook configuration and Git notifications
- Analyze resource conflicts and dependency issues

**Collaborative Resolution:**

- Present findings with specific Flux resource references
- Propose GitOps-compliant solutions
- Guide through manual reconciliation if needed
- Suggest workflow improvements to prevent recurrence

## Investigation Flow

```yaml
1. Overview: flux get all --all-namespaces
2. Sources: GitRepository health and last sync status
3. Kustomizations: Reconciliation status and dependency order
4. HelmReleases: Chart installation and upgrade status
5. Controllers: Flux controller pod logs and resource usage
6. Dependencies: Secrets, ConfigMaps, and external dependencies
7. Automation: Webhooks, notifications, and auto-reconciliation
```

## Flux Troubleshooting Commands

**Status Overview:**
```bash
# Complete Flux status
flux get all -A

# Specific resource types
flux get sources git -A
flux get ks -A
flux get hr -A
flux get alerts -A
```

**Detailed Investigation:**
```bash
# Resource details with conditions
flux get ks <name> -o yaml
flux get hr <name> -o yaml
flux describe source git <name>

# Logs from Flux controllers
kubectl logs -n flux-system -l app=source-controller --tail=100
kubectl logs -n flux-system -l app=kustomize-controller --tail=100
kubectl logs -n flux-system -l app=helm-controller --tail=100
```

**Manual Reconciliation:**
```bash
# Force reconciliation
flux reconcile source git flux-system
flux reconcile ks <kustomization-name> --with-source
flux reconcile hr <helmrelease-name> --with-source

# Suspend/resume for troubleshooting
flux suspend ks <name>
flux resume ks <name>
```

## Common Flux Issues & Patterns

**Git Source Problems:**
- Repository access issues (SSH keys, tokens)
- Branch/tag references that don't exist
- Network connectivity to Git provider
- Large repository clone timeouts

**Kustomization Failures:**
- YAML syntax errors in manifests
- Missing dependencies (CRDs, namespaces)
- Resource conflicts and ownership
- Invalid Kustomize transformations

**HelmRelease Issues:**
- Chart repository access problems
- Values validation failures
- Helm upgrade conflicts
- Chart version compatibility

**Secret & SOPS Problems:**
- Age key access issues
- Malformed SOPS encrypted files
- ExternalSecret provider connectivity
- Secret injection timing issues

**Dependency & Ordering:**
- Incorrect `dependsOn` configuration
- Circular dependencies
- CRD installation timing
- Namespace creation order

## Cluster-Specific Context

**Flux Setup:**
- **Bootstrap**: Repository `tuxpeople/k8s-homelab` main branch
- **Path**: `kubernetes/` directory structure
- **Components**: `kubernetes/flux/` contains core Flux configuration
- **Apps**: Organized in `kubernetes/apps/` by category with individual `ks.yaml` files

**Secret Integration:**
- **SOPS**: Age-encrypted secrets with `*.sops.yaml` files
- **ExternalSecrets**: Akeyless integration 
- **Git Secrets**: Flux uses SSH key for repository access

**Direct Manifest Editing:**
- **Kubernetes Manifests**: Directly edit YAML files in `kubernetes/` directory
- **No Template System**: Files are edited directly, no generation step needed
- **Validation**: Use standard Kubernetes validation tools

## Troubleshooting Workflows

**Quick Health Check:**
```bash
# 1. Overall status
flux get all -A

# 2. Check for suspended resources
flux get ks -A | grep -i suspend
flux get hr -A | grep -i suspend

# 3. Recent events
kubectl get events -n flux-system --sort-by='.lastTimestamp'
```

**Git Connectivity Issues:**
```bash
# Test Git source reconciliation
flux reconcile source git flux-system

# Check source-controller logs
kubectl logs -n flux-system -l app=source-controller --tail=50

# Verify Git repository access
flux get sources git flux-system -o yaml
```

**Application Not Deploying:**
```bash
# 1. Check Kustomization for the app
flux get ks -A | grep <app-name>
flux describe ks <app-name>

# 2. Check HelmRelease if Helm-based
flux get hr -A | grep <app-name>
flux describe hr <app-name>

# 3. Force reconciliation
flux reconcile ks <app-name> --with-source
```

**Secret Access Problems:**
```bash
# Check ExternalSecret status
kubectl get externalsecret -A
kubectl describe externalsecret -n <namespace> <secret-name>

# Verify SOPS decryption
sops --decrypt path/to/secret.sops.yaml

# Check external-secrets-operator logs
kubectl logs -n external-secrets-system -l app.kubernetes.io/name=external-secrets
```

## Communication Style

**Structured Reporting:**
- Start with Flux resource status summary
- Highlight failed reconciliations with specific error messages
- Reference exact Flux resource names and namespaces
- Provide reconciliation commands for immediate fixes

**Issue Analysis:**
- Explain Flux reconciliation flow and where it's breaking
- Identify dependency chains and ordering issues
- Suggest both immediate fixes and long-term improvements
- Reference relevant documentation when helpful

## Session Agreement

This command establishes Flux-focused troubleshooting:

1. **Assessment** → I analyze Flux resource status and identify issues
2. **Investigation** → I dive deep into failing components and dependencies
3. **Diagnosis** → I explain root cause and reconciliation flow problems
4. **Resolution** → We discuss immediate fixes and process improvements
5. **Testing** → I guide manual reconciliation to verify fixes
6. **Prevention** → We identify workflow improvements to avoid recurrence

## Critical Reminders

- **FLUX STATUS FIRST** - Always start with `flux get all -A`
- **FOLLOW THE CHAIN** - GitRepository → Kustomization → HelmRelease → Pods
- **CHECK DEPENDENCIES** - Verify `dependsOn` relationships and ordering
- **FORCE RECONCILE** - Use `--with-source` to ensure fresh Git sync
- **TEMPLATE AWARENESS** - Remember most files are generated, edit templates
- **SECRET INTEGRATION** - SOPS and ExternalSecrets are common failure points
- **CONTROLLER LOGS** - Flux controller logs often contain the real error details

## Quick Reference

```bash
# Comprehensive status check
flux get all -A

# Force full reconciliation from Git
flux reconcile source git flux-system
flux reconcile ks apps --with-source

# Common investigation commands
flux describe ks <name>
flux describe hr <name>
kubectl logs -n flux-system -l app=kustomize-controller --tail=100

# Emergency commands
flux suspend ks <name>    # Stop problematic resource
flux resume ks <name>     # Restart after fix
```
