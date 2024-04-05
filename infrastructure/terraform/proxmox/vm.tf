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

  password = nonsensitive(data.doppler_secrets.this.map.PX_PASSWORD)
}

module "kubernetes" {
  source   = "./talos"
  for_each = local.nodes

  name      = "kubernetes-${each.key}"
  node_name = each.key
  cpu       = local.nodes[each.key].cpu
  sockets   = local.nodes[each.key].sockets
  memory    = local.nodes[each.key].memory
  disk_size = 16

  iso_id      = proxmox_virtual_environment_file.talos_iso[each.key].id
  vm_id       = 2001 + index(keys(local.nodes), each.key)
  mac_address = "42:C3:B0:6B:80:E${index(keys(local.nodes), each.key) + 1}"

  providers = {
    doppler = doppler
    proxmox = proxmox
  }
}

