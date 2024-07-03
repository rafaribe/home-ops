# Would be nice to use a dynamic block to avoid repitition, but oh well.
resource "proxmox_virtual_environment_file" "opnsense_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "truenas"
  node_name    = each.key

  source_file {
    path      = "https://mirror.ams1.nl.leaseweb.net/opnsense/releases/24.1/OPNsense-24.1-dvd-amd64.iso.bz2"
    file_name = "OPNsense-24.1-dvd-amd64.iso"
  }
}

resource "proxmox_virtual_environment_file" "nix_os_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    path      = "/home/rafaribe/Downloads/nixos-minimal-24.05.2411.706eef542dec-x86_64-linux.iso"
    file_name = "nixos-minimal-24.05.iso"
  }
}
