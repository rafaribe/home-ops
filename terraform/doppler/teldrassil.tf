module "cert-manager" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "cert-manager"
  environments  = ["dev", "prod"]
}

module "cloudflare" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "cloudflare"
  environments  = ["dev", "prod"]
}

module "authentik" {
  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "authentik"
  environments  = ["prod"]
}
