provider "authentik" {
  url   = data.sops_file.authentik-secrets.data["authentik_api_url"]
  token = data.sops_file.authentik-secrets.data["authentik_api_token"]
}
provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"

  api_key_login {
    access_id  = data.sops_file.authentik-secrets.data["akeyless_access_id"]
    access_key = data.sops_file.authentik-secrets.data["akeyless_access_secret"]
  }
}