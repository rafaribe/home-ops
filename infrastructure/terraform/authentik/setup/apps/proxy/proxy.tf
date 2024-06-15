data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "proxy_provider" {
  name               = var.authentik_proxy_application_name
  external_host      = var.authentik_proxy_external_host
  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  mode               = "forward_single"

  depends_on = [
    data.authentik_flow.default-authorization-flow
  ]
}

locals {
  application_name_normalized = replace(trimspace(var.authentik_proxy_application_name), " ", "-")
}

resource "authentik_application" "name" {

  name              = local.application_name_normalized
  slug              = local.application_name_normalized
  protocol_provider = authentik_provider_proxy.proxy_provider.id
  group             = var.authentik_proxy_application_group
  meta_icon         = var.authentik_proxy_application_icon_url
  meta_description  = var.authentik_proxy_application_description

  depends_on = [
    authentik_provider_proxy.proxy_provider
  ]

}
