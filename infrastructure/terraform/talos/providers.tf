terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.2.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
  }
}
data "sops_file" "secrets" {
  source_file = "../terraform.sops.yaml"
}
