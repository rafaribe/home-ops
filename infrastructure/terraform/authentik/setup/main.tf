terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

