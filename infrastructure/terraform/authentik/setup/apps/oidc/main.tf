
terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.10.0"
      configuration_aliases = [ authentik.oidc ]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

