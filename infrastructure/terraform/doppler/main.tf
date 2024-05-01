terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-doppler"
    }
  }
  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.7.1"
    }
  }
}
