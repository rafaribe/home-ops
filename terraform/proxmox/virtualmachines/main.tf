terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.92.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}
