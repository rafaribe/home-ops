terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version               = "2023.5.0"
      configuration_aliases = [authentik.proxy]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
