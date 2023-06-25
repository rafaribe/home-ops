## How to bootstrap

Assuming you are in the `cluster-0` root folder:

### Flux

#### Install Flux

```sh
kubectl apply --server-side --kustomize ./bootstrap/flux
```

### Apply Cluster Configuration

_These cannot be applied with `kubectl` in the regular fashion due to some files being encrypted with sops_

```sh
sops --decrypt ./bootstrap/flux/age-key.sops.yaml | kubectl apply -f -
kubectl apply -f ./flux/vars/cluster-config.yaml
```

### Manually apply Prom CRD'

This helps avoid dependency hell with many startup helmreleases needing prometheus crd's first. When prometheus CRD reconciles it will take over these

```sh
kubectl apply  -k ./bootstrap/crds/
```

### Kick off Flux applying this repository

```sh
kubectl apply --server-side --kustomize ./flux/config
```
