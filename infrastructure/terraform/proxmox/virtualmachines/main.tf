terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
  }
}
