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

module "tfcontroller" {
  source       = "./project"
  project_name = "tfcontroller"
  environments = ["nordrassil", "skovald"]
  providers = {
    doppler = doppler
  }
}

module "proxmox" {
  source       = "./project"
  project_name = "proxmox"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "cloudnativepg" {
  source       = "./project"
  project_name = "cloudnativepg"
  environments = ["nordrassil", "skovald"]
  providers = {
    doppler = doppler
  }
}

module "minio" {
  source       = "./project"
  project_name = "minio"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "pgadmin" {
  source       = "./project"
  project_name = "pgadmin"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "grafana" {
  source       = "./project"
  project_name = "grafana"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "prometheus" {
  source       = "./project"
  project_name = "prometheus"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "loki" {
  source       = "./project"
  project_name = "loki"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
