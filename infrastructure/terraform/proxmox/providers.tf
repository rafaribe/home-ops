terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.62.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }
  }
}
data "sops_file" "secrets" {
  source_file = "../terraform.sops.yaml"
}

# Inject secrets from doppler into Unifi Provider
provider "proxmox" {
  endpoint = data.sops_file.secrets.data["proxmox_endpoint"]
  username = data.sops_file.secrets.data["proxmox_username"]
  password = data.sops_file.secrets.data["proxmox_password"]
  insecure = true
}
