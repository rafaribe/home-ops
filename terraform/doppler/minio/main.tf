terraform {

  required_providers {

    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.1.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}
provider "doppler" {
  doppler_token = var.doppler_token
}
