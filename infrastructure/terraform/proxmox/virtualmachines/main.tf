terraform {

  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.7.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.51.1"
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
