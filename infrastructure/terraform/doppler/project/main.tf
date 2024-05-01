terraform {

  required_providers {

    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.7.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
