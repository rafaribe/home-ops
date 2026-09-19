terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version = "2026.8.0"
      configuration_aliases = [authentik]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
