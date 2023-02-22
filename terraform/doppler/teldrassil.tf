module "cert-manager" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project_name  = "cert-manager"
  environments  = ["dev", "prod"]
}

module "cloudflare" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project_name  = "cloudflare"
  environments  = ["dev", "prod"]
}

module "authentik" {
  source        = "./project"
  doppler_token = var.dopplerToken
  project_name  = "authentik"
  environments  = ["prod"]
}
module "unifi" {
  source        = "./project"
  doppler_token = var.dopplerToken
  project_name  = "unifi"
  environments  = ["prod"]
}

module "test" {
  source        = "./project"
  doppler_token = var.dopplerToken
  project_name  = "test"
  environments  = ["prod"]
}

