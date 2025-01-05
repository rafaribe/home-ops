
locals {
  external_host = data.sops_file.authentik-secrets.data["authentik_external_host"]
}