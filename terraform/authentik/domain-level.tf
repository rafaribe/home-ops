data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "name" {
  name               = "forward-auth-domain"
  mode               = "forward_domain"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  external_host      = var.authentik_domain_proxy_external_url
}

resource "authentik_application" "name" {
  name              = "domain-auth"
  slug              = "domain-auth"
  protocol_provider = authentik_provider_proxy.name.id
}
