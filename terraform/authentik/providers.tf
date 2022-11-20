provider "authentik" {
  url      = var.authentik_api_url
  token    = var.authentik_api_token
  insecure = false
}
