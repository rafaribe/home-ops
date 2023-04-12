terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

