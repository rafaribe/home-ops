terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.4.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }
}
data "sops_file" "secrets" {
  source_file = "../terraform.sops.yaml"
}
