terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.4.0"
      configuration_aliases = [ authentik.setup ]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}


