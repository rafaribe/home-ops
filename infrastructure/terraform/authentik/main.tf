
terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-authentik"
    }
  }
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.4.2"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.8.0"
    }
  }
}
