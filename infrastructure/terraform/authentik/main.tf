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
      version = "2024.10.2"
    }
    
    sops = {
      source = "carlpett/sops"
      version = "1.1.1"
    }
  }
}