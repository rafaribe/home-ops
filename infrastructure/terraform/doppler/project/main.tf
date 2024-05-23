terraform {

  required_providers {

    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.6.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
