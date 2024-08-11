locals {
  nix_nodes = {
    "nix" = {
      cpu     = 2
      sockets = 1
      memory  = 2048
    }

  }

  talos_nodes = {
    "utils-1" = {
      cpu     = 2
      sockets = 1
      memory  = 8192
    }
  }
  proxmox_node_name = "router"

  password = data.sops_file.secrets.data["proxmox_password"]
}
