terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version = "2024.12.1"
      configuration_aliases = [authentik]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
  }
}
