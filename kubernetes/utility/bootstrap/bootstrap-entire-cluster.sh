#!/usr/bin/env bash
echo "Bootstrapping CRD's"
kubectl apply -k crds/

echo "Bootstrapping Flux"
kubectl create namespace flux-system
sops -d ./flux/age-key.sops.yaml | kubectl apply -f -
sops -d ./flux/github-deploy-key.sops.yaml | kubectl apply -f -
kubectl apply -k flux/
echo "Applying flux manifests"
cd ../flux
echo "Applying bootstrap flux again"
kubectl apply -k bootstrap/
echo "Applying repositories"
kubectl apply -k repositories
sops -d ./vars/cluster-secrets.yaml | kubectl apply -f -
echo "Applying vars"
kubectl apply -k vars/

echo "Applying config"
kubectl apply -k config/
echo "Applying apps"
kubectl apply -f apps.yaml
