output "all_nodes" {
  value = data.proxmox_virtual_environment_nodes.available_nodes.names
}
