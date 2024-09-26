terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.65.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
