module "cert-manager" {

  source       = "./project"
  project_name = "cert-manager"
  environments = ["dev", "prod"]
  providers = {
    doppler = doppler
  }
}

module "cloudflare" {

  source       = "./project"
  project_name = "cloudflare"
  environments = ["dev", "prod"]
  providers = {
    doppler = doppler
  }
}

module "authentik" {
  source       = "./project"
  project_name = "authentik"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "unifi" {
  source       = "./project"
  project_name = "unifi"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "flux" {
  source       = "./project"
  project_name = "flux"
  environments = ["webhook", "nordrassil", "skovald"]
  providers = {
    doppler = doppler
  }
}

