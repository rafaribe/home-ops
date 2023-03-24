data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

resource "random_password" "random_client_secret" {
  length  = 128
  special = false
}

resource "random_id" "random_client_id" {
  byte_length = 40
}

data "authentik_scope_mapping" "property_mappings" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
  ]
}

resource "authentik_provider_oauth2" "oidc_provider" {
  name               = var.authentik_oidc_application_name
  client_id          = random_id.random_client_id.dec
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  client_secret      = random_password.random_client_secret.result
  property_mappings  = data.authentik_scope_mapping.property_mappings.ids
  signing_key        = data.authentik_certificate_key_pair.generated.id

  depends_on = [
    random_id.random_client_id,
    random_password.random_client_secret,
    data.authentik_certificate_key_pair.generated,
    data.authentik_scope_mapping.property_mappings,
    data.authentik_flow.default-authorization-flow
  ]
}

locals {
  application_name_normalized = replace(trimspace(var.authentik_oidc_application_name), " ", "-")
}

resource "authentik_application" "application" {

  name              = local.application_name_normalized
  slug              = local.application_name_normalized
  protocol_provider = authentik_provider_oauth2.oidc_provider.id
  group             = var.authentik_oidc_application_group
  meta_icon         = var.authentik_oidc_application_icon_url
  meta_description  = var.authentik_oidc_application_description

  depends_on = [
    authentik_provider_oauth2.oidc_provider
  ]

}
