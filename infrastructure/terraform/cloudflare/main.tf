terraform {

  required_version = ">= 1.3.0"
  cloud {
    hostname     = "app.terraform.io"
    organization = "rafaribe"

    workspaces {
      name = "home-cloudflare"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.26.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }
  }
}

# Obtain current home IP address
data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

data "cloudflare_zones" "domain_com" {
  filter {
    name = var.cloudflare_domain_com
  }
}
