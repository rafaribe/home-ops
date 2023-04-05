resource "proxmox_virtual_environment_file" "talos_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    path = "https://github.com/siderolabs/talos/releases/download/v1.3.5/talos-amd64.iso"
  }
}

resource "proxmox_virtual_environment_file" "ubuntu_22_04_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    path = "https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso"
  }
}


resource "proxmox_virtual_environment_file" "fedora_coreos_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    path = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230322.3.0/x86_64/fedora-coreos-37.20230322.3.0-live.x86_64.iso"
  }
}

