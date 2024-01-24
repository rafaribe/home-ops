terraform {

  required_providers {

    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
