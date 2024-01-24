terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name           = "home-proxmox"
      execution_mode = "local"
    }

  }
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
  }
}
