terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-unifi"
    }
  }
  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.1.7"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.40.0"
    }
  }
}
