terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version               = "2024.6.0"
      configuration_aliases = [authentik.proxy]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
