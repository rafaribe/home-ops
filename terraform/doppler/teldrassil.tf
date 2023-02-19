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

module "prometheus" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "prometheus"
  environments  = ["prod"]
}

module "grafana" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "grafana"
  environments  = ["prod"]
}

module "loki" {

  source        = "./project"
  doppler_token = var.dopplerToken
  project-name  = "loki"
  environments  = ["prod"]
}
