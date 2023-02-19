module "cert-manager" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "cert-manager"
  environments  = ["prod"]
}

module "cloudflare" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "cloudflare"
  environments  = ["prod"]
}

module "authentik" {
  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "cloudflare"
  environments  = ["prod"]
}
