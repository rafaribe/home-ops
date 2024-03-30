terraform {

  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.6.2"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.51.0"
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
