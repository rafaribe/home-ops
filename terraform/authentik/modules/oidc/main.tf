terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version               = "2025.10.1"
      configuration_aliases = [authentik]
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    akeyless = {
      version = ">= 1.0.0"
      source  = "akeyless-community/akeyless"
    }
  }
}
