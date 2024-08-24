terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
