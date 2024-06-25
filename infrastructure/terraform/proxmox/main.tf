terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-proxmox"
    }

  }
  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.8.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.60.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
