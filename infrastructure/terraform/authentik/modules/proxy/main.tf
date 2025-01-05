terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version = "2024.10.2"
      configuration_aliases = [authentik]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}
