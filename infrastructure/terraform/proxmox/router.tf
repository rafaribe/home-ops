module "opnsense" {
  source   = "./virtualmachines"
  for_each = local.router_nodes

  name      = "opnsense-${each.key}"
  node_name = each.key
  cpu       = local.router_nodes[each.key].cpu
  sockets   = local.router_nodes[each.key].sockets
  memory    = local.router_nodes[each.key].memory
  disk_size = 70

  iso_id      = proxmox_virtual_environment_file.opnsense[each.key].id
  vm_id       = 1000 + index(keys(local.router_nodes), each.key)
  mac_address = "42:C3:B0:6B:80:A${index(keys(local.router_nodes), each.key) + 1}"
  tags        = ["opnsense", "router", "terraform"]
  providers = {
    doppler = doppler
    proxmox = proxmox
  }
}
