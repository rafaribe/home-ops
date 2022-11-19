
terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-authentik"
    }
  }

  required_providers {
    provider "authentik" {
    url   = "https://beryjuorg-dev.my.goauthentik.io"
    token = "foo-bar"
    # Optionally set insecure to ignore TLS Certificates
    # insecure = true
    }
  }
}
