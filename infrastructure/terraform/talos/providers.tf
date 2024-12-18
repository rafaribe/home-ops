terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0"
    }
  }
}
data "sops_file" "secrets" {
  source_file = "../terraform.sops.yaml"
}
