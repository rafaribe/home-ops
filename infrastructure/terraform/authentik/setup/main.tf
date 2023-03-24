terraform {

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}
provider "authentik" {
  
  url      = var.authentik_api_url
  token    = var.authentik_api_token
  insecure = false
}

