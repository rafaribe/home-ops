resource "random_password" "this" {
  length  = 128
  special = false
}

resource "random_id" "this" {
  byte_length = 40
}

resource "authentik_provider_oauth2" "oidc_provider" {
  name               = var.authentik_oidc_application_name
  client_id          = random_id.this.dec
  authorization_flow = data.authentik_flow.this.id
  client_secret      = random_password.this.result
  property_mappings  = data.authentik_property_mapping_provider_scope.this.ids
  signing_key        = data.authentik_certificate_key_pair.this.id
  invalidation_flow  = data.authentik_flow.invalidation.id

}
