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
  environments = ["webhook", "truenas", "skovald"]
  providers = {
    doppler = doppler
  }
}

module "tfcontroller" {
  source       = "./project"
  project_name = "tfcontroller"
  environments = ["truenas", "skovald"]
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
  environments = ["truenas"]
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

module "alertmanager" {
  source       = "./project"
  project_name = "alertmanager"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "webhook_discord" {
  source       = "./project"
  project_name = "webhook_discord"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "paperless" {
  source       = "./project"
  project_name = "paperless"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "gatus" {
  source       = "./project"
  project_name = "gatus"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}


module "volsync" {
  source       = "./project"
  project_name = "volsync"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}


module "rook-ceph" {
  source       = "./project"
  project_name = "rook-ceph"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "actions-runner-controller" {
  source       = "./project"
  project_name = "actions-runner-controller"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "plex" {
  source       = "./project"
  project_name = "plex"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "prowlarr" {
  source       = "./project"
  project_name = "prowlarr"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "radarr" {
  source       = "./project"
  project_name = "radarr"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}


module "recyclarr" {
  source       = "./project"
  project_name = "recyclarr"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "sonarr" {
  source       = "./project"
  project_name = "sonarr"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "unpackerr" {
  source       = "./project"
  project_name = "unpackerr"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "emqx" {
  source       = "./project"
  project_name = "emqx"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}

module "hass" {
  source       = "./project"
  project_name = "hass"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}


module "sabnbzd" {
  source       = "./project"
  project_name = "sabnbzd"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
module "readarr" {
  source       = "./project"
  project_name = "readarr"
  environments = ["prod"]
  providers = {
    doppler = doppler
  }
}
