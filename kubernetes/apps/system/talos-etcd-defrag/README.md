# Talos ETCD Defragmentation CronJob

This CronJob performs weekly etcd defragmentation on controlplane nodes using a distributed approach where each controlplane node defragments its own etcd database.

## Architecture

### Distributed Execution
Instead of a single job discovering and processing all nodes, this implementation:

1. **Schedules pods only on controlplane nodes** using `nodeSelector` and `tolerations`
2. **Injects node information** via environment variables (`NODE_NAME`, `NODE_IP`)
3. **Each pod defragments its own node's etcd** using `talosctl -n $NODE_IP etcd defrag`
4. **Runs in parallel** across all controlplane nodes simultaneously

### Benefits
- **🚀 Faster**: Parallel execution instead of sequential
- **🎯 Targeted**: Each node handles only its own etcd
- **🔒 Secure**: Uses node's own IP, no cross-node discovery needed
- **📊 Clear Logging**: Each node's logs are separate and identifiable
- **⚡ Efficient**: No kubectl API calls to discover nodes

## Technical Implementation

### Node Scheduling
```yaml
nodeSelector:
  node-role.kubernetes.io/control-plane: ""
tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
```

### Environment Variable Injection
```yaml
env:
  NODE_NAME:
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  NODE_IP:
    valueFrom:
      fieldRef:
        fieldPath: status.hostIP
```

### Service Accounts

This implementation uses both Kubernetes and Talos ServiceAccounts:

1. **Kubernetes ServiceAccount**: `talos-etcd-defrag`
   - Used for pod scheduling and Kubernetes RBAC
   - Referenced in the HelmRelease `serviceAccount.name`

2. **Talos ServiceAccount**: `talos-etcd-defrag` 
   - Has `os:admin` role for etcd operations
   - Automatically creates secret `talos-etcd-defrag-talos-secrets`
   - Mounted at `/var/run/secrets/talos.dev`

### Node Scheduling Configuration
```yaml
defaultPodOptions:
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
  tolerations:
    - key: node-role.kubernetes.io/control-plane
      operator: Exists
      effect: NoSchedule
```

## Prerequisites

The following must be configured in your Talos cluster (already done in this setup):

1. **Talos API Access Feature Enabled**:
   ```yaml
   machine:
     features:
       kubernetesTalosAPIAccess:
         enabled: true
         allowedRoles:
           - os:admin
         allowedKubernetesNamespaces:
           - system
   ```

2. **Controlplane Node Labels**: Nodes must have `node-role.kubernetes.io/control-plane` label

## Schedule

- **Frequency**: Weekly on Sunday at 2:00 AM (Europe/Lisbon timezone)
- **Concurrency**: Forbid (prevents overlapping executions)
- **History**: Keeps 3 successful and 3 failed job logs
- **Execution**: Parallel across all controlplane nodes

## Operation Flow

For each controlplane node:

1. **Pod Scheduling**: CronJob creates a pod on the controlplane node
2. **Environment Injection**: Node name and IP are injected as environment variables
3. **Etcd Defragmentation**: Pod runs `talosctl -n $NODE_IP etcd defrag`
4. **Logging**: Detailed logs with node identification
5. **Completion**: Pod reports success/failure and terminates

## Monitoring

### View All Jobs
```bash
# Check all etcd defrag jobs
kubectl get jobs -n system -l app.kubernetes.io/name=talos-etcd-defrag

# Check cronjob status
kubectl get cronjobs -n system talos-etcd-defrag
```

### View Logs by Node
```bash
# Get all pods from the latest job
kubectl get pods -n system -l app.kubernetes.io/name=talos-etcd-defrag --sort-by=.spec.nodeName

# View logs for a specific node's pod
kubectl logs -n system <pod-name>

# Follow logs for all pods in the latest job
kubectl logs -n system -l job-name=<job-name> -f
```

### Log Format
Each pod logs will show:
```
Starting etcd defragmentation on local controlplane node...
Timestamp: Sun Jan 15 02:00:00 UTC 2025
Node: main-srv-02.home.arpa
Node IP: 10.0.1.15
Running: talosctl -n 10.0.1.15 etcd defrag
✅ Successfully defragmented etcd on main-srv-02.home.arpa (10.0.1.15)
Defragmentation completed at: Sun Jan 15 02:00:45 UTC 2025
```

## Manual Execution

### Trigger All Nodes
```bash
# Create a manual job (will run on all controlplane nodes)
kubectl create job --from=cronjob/talos-etcd-defrag manual-defrag-$(date +%s) -n system
```

### Test Single Node
```bash
# Create a test pod on a specific node
kubectl run talos-etcd-test --image=ghcr.io/siderolabs/talosctl:v1.10.4 \
  --rm -it --restart=Never -n system \
  --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"main-srv-02.home.arpa"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}}' \
  -- talosctl -n 10.0.1.15 etcd defrag
```

## Troubleshooting

### Check Node Scheduling
```bash
# Verify controlplane nodes
kubectl get nodes -l node-role.kubernetes.io/control-plane

# Check if pods are scheduled correctly
kubectl get pods -n system -l app.kubernetes.io/name=talos-etcd-defrag -o wide
```

### Verify Environment Variables
```bash
# Check if NODE_IP is injected correctly
kubectl logs -n system <pod-name> | grep "Node IP:"
```

### Test Talos ServiceAccount
```bash
# Check Talos ServiceAccount
kubectl get talosserviceaccounts -n system
kubectl describe talosserviceaccount talos-etcd-defrag-talos-secrets -n system

# Verify secret mount
kubectl get secret talos-etcd-defrag-talos-secrets -n system
```

This distributed approach is much more efficient and follows cloud-native patterns where each node is responsible for its own maintenance tasks.
