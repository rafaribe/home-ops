#Create a local kubernetes connection

#Ask on Discord how to do it.
#Create a remote kubernetes connection
resource "authentik_service_connection_kubernetes" "cluster-svc-connection" {
  name       = var.authentik_application_group
  kubeconfig = var.authentik_kubeconfig
}

resource "authentik_outpost" "outpost" {
  name               = "${var.authentik_application_group}-outpost"
  protocol_providers = var.authentik_proxy_provider_ids
  service_connection = authentik_service_connection_kubernetes.cluster-svc-connection.id
  config             = var.authentik_outpost_config

  depends_on = [
    authentik_service_connection_kubernetes.cluster-svc-connection
  ]
}
