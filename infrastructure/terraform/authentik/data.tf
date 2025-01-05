data "sops_file" "authentik-secrets" {
  source_file = "../terraform.sops.yaml"
}