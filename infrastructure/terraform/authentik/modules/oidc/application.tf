locals {
  application_name_normalized = replace(trimspace(var.authentik_oidc_application_name), " ", "-")
}

resource "authentik_application" "this" {

  name              = local.application_name_normalized
  slug              = local.application_name_normalized
  protocol_provider = authentik_provider_oauth2.oidc_provider.id
  group             = var.authentik_oidc_application_group
  meta_icon         = var.authentik_oidc_application_icon_url
  meta_description  = var.authentik_oidc_application_description

}
