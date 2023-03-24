terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.12.0"
      configuration_aliases = [ authentik.setup ]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}



