terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version               = "2025.2.0"
      configuration_aliases = [authentik]
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    akeyless = {
      version = ">= 1.0.0"
      source  = "akeyless-community/akeyless"
    }
  }
}
