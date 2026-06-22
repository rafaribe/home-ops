terraform {

  backend "s3" {
    bucket   = "terraform"
    key      = "authentik/terraform.tfstate"
    region   = "us-east-1"
    endpoint = "https://s3.rafaribe.com"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.5.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.4.1"
    }
    # To Automatically create OIDC Secrets into akeyless
    akeyless = {
      version = ">= 1.0.0"
      source  = "akeyless-community/akeyless"
    }
  }
}
