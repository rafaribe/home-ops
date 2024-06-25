terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-minio"
    }
  }
  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.8.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "2.3.2"
    }
  }
}
