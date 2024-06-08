resource "random_bytes" "tunnel_secret" {
  length = 32
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = "home-ops"
  secret     = random_bytes.tunnel_secret.base64
}

output "tunnel_secret" {
  value = random_bytes.tunnel_secret.base64
}
