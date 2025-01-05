provider "authentik" {
  url   = "${data.sops_file.authentik-secrets.data["authentik_api_url"]}"
  token = "${data.sops_file.authentik-secrets.data["authentik_api_token"]}"
}
