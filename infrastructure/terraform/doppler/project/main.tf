terraform {

  required_providers {

    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
