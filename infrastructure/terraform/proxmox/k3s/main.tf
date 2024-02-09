terraform {

  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.6.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.45.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
