resource "proxmox_virtual_environment_time" "first_node_time" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  node_name = each.key
  time_zone = "GMT"
}
