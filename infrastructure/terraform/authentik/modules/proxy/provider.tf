data "authentik_flow" "this" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "invalidation" {
  slug = "default-provider-invalidation-flow"
}

resource "authentik_provider_proxy" "this" {
  name               = var.authentik_proxy_application_name
  external_host      = var.authentik_proxy_external_host
  authorization_flow = data.authentik_flow.this.id
  mode               = "forward_single"
  invalidation_flow  = data.authentik_flow.invalidation.id
}
