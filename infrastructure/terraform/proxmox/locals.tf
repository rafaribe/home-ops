locals {
  nodes = {
    "odin" = {
      cpu     = 4
      sockets = 2
      memory  = 16000
    }
    "loki" = {
      cpu     = 4
      sockets = 1
      memory  = 16000
    }
    "thor" = {
      cpu     = 4
      sockets = 1
      memory  = 16000
    }
    "freya" = {
      cpu     = 4
      sockets = 1
      memory  = 16000
    }
    "tyr" = {
      cpu     = 4
      sockets = 2
      memory  = 32000
    }
  }

  router_nodes = {
    "router" = {
      cpu     = 2
      sockets = 1
      memory  = 4096
    }
  }

  password = data.sops_file.secrets.data["proxmox_password"]
}
