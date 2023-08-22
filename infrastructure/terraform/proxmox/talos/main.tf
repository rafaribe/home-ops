terraform {

  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.2.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.30.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
