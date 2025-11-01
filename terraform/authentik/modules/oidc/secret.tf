locals {
  akeyless_secret_path = "/${var.authentik_oidc_application_name}/oidc"
}

resource "akeyless_static_secret" "oidc_secret" {
  count  = var.create_akeyless_secret ? 1 : 0
  path   = local.akeyless_secret_path
  format = "json"
  value = jsonencode({
    OIDC_CLIENT_ID     = random_id.this.dec
    OIDC_CLIENT_SECRET = random_password.this.result
  })
}
