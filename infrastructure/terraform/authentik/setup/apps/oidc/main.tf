
terraform {

  required_providers {
    authentik = {
      source                = "goauthentik/authentik"
      version               = "2024.2.0"
      configuration_aliases = [authentik.oidc]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

