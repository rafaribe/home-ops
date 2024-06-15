

# module "kubernetes" {
#   source   = "./virtualmachines"
#   for_each = local.nodes

#   name      = "kubernetes-${each.key}"
#   node_name = each.key
#   cpu       = local.nodes[each.key].cpu
#   sockets   = local.nodes[each.key].sockets
#   memory    = local.nodes[each.key].memory
#   disk_size = 70

#   iso_id      = proxmox_virtual_environment_file.debian_iso[each.key].id
#   vm_id       = 2001 + index(keys(local.nodes), each.key)
#   mac_address = "42:C3:B0:6B:80:E${index(keys(local.nodes), each.key) + 1}"
#   tags        = ["debian", "kubernetes", "terraform"]
#   providers = {
#     doppler = doppler
#     proxmox = proxmox
#   }
#}
