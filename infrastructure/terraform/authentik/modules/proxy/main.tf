terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version = "2025.4.0"
      configuration_aliases = [authentik]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
