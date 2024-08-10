locals {
  nix_nodes = {
    "nix" = {
      cpu     = 2
      sockets = 1
      memory  = 2048
    }

  }

  talos_nodes = {
    "talos1" = {
      cpu     = 2
      sockets = 1
      memory  = 4096
    }
  }
  proxmox_node_name = "router"

  password = data.sops_file.secrets.data["proxmox_password"]
}
