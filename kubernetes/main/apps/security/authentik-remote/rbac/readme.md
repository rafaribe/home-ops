#helm template authentik-remote authentik/authentik-remote-cluster -n security --set fullnameOverride=authentik-remote > tmpl.yaml
kubectl view-serviceaccount-kubeconfig authentik-remote -n security -o json > kubeconfig.json
