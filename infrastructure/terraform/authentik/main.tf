terraform {

  backend "s3" {
    bucket = "terraform-state"
    key    = "authentik/terraform.tfstate"
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.6.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.2.1"
    }
    # To Automatically create OIDC Secrets into akeyless
    akeyless = {
      version = ">= 1.0.0"
      source  = "akeyless-community/akeyless"
    }
  }
}
