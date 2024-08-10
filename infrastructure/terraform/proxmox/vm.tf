module "nixos" {
  source   = "./virtualmachines"
  for_each = local.nix_nodes

  name      = "nixos-${each.key}"
  node_name = each.key
  cpu       = local.nix_nodes[each.key].cpu
  sockets   = local.nix_nodes[each.key].sockets
  memory    = local.nix_nodes[each.key].memory
  disk_size = 20

  iso_id       = proxmox_virtual_environment_file.nix_os_iso[local.proxmox_node_name].id
  vm_id        = 2000 + index(keys(local.nix_nodes), each.key)
  mac_address  = "42:C3:B0:6B:80:B${index(keys(local.nix_nodes), each.key) + 1}"
  tags         = ["nixos", "network-tooling", "terraform"]
  network_boot = false
  agent        = false
  providers = {
    proxmox = proxmox
  }
}

module "talos" {
  source   = "./virtualmachines"
  for_each = local.talos_nodes

  name      = "talos-${each.key}"
  node_name = each.key
  cpu       = local.talos_nodes[each.key].cpu
  sockets   = local.talos_nodes[each.key].sockets
  memory    = local.talos_nodes[each.key].memory
  disk_size = 20

  iso_id       = proxmox_virtual_environment_file.talos_os_iso[local.proxmox_node_name].id
  vm_id        = 2000 + index(keys(local.talos_nodes), each.key)
  mac_address  = "42:C3:B0:6B:80:C${index(keys(local.talos_nodes), each.key) + 1}"
  tags         = ["talos", "tooling", "terraform", "utils"]
  network_boot = true
  agent        = false
  providers = {
    proxmox = proxmox
  }
}
