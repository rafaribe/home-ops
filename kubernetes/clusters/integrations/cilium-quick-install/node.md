# Cilium Quick Install

quick-install created by:

```sh
echo "Creating cilium-system namespace and templating cilium-quick-install manifests to apply" && \
helm template -f ./kubernetes/clusters/integrations/cilium-quick-install/values.yaml cilium/cilium -n kube-system > ./kubernetes/clusters/integrations/cilium-quick-install/quick-install-temp.yaml && \
yq eval-all 'select(fileIndex == 0) *d select(fileIndex == 1)' ./kubernetes/clusters/integrations/cilium-quick-install/quick-install-temp.yaml ./kubernetes/clusters/integrations/cilium-quick-install/namespace.yaml > ./kubernetes/clusters/integrations/cilium-quick-install/quick-install.yaml && \
rm ./kubernetes/clusters/integrations/cilium-quick-install/quick-install-temp.yaml && \
echo "Done templating cilium manifests"
```
