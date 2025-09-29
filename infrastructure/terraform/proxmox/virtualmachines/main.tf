terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
