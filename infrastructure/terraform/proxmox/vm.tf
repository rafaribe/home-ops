# module "nixos" {
#   source   = "./virtualmachines"
#   for_each = local.router_nodes

#   name      = "nixos-${each.key}"
#   node_name = each.key
#   cpu       = local.router_nodes[each.key].cpu
#   sockets   = local.router_nodes[each.key].sockets
#   memory    = local.router_nodes[each.key].memory
#   disk_size = 20

#   iso_id      = proxmox_virtual_environment_file.nix_os_iso[each.key].id
#   vm_id       = 2000 + index(keys(local.router_nodes), each.key)
#   mac_address = "42:C3:B0:6B:80:B${index(keys(local.router_nodes), each.key) + 1}"
#   tags        = ["nixos", "network-tooling", "terraform"]
#   providers = {
#     proxmox = proxmox
#   }
# }
