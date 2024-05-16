terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.4.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

