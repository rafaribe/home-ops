terraform {

  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.4.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.41.0"
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
