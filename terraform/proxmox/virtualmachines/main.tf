terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.122.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.4.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
