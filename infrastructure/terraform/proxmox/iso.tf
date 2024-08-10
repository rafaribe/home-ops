# Would be nice to use a dynamic block to avoid repitition, but oh well.
resource "proxmox_virtual_environment_file" "opnsense_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    path      = "https://mirror.leitecastro.com/opnsense/releases/mirror/OPNsense-24.7-dvd-amd64.iso.bz2"
    file_name = "OPNsense-24.7-dvd-amd64.iso"
  }
}

resource "proxmox_virtual_environment_file" "nix_os_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    path      = "https://mirror.nju.edu.cn/nixos-images/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso" # China NixOS Mirror https://mirrors.cernet.edu.cn/os/NixOS
    file_name = "nixos-minimal-24.05.iso"
  }
}

resource "proxmox_virtual_environment_file" "talos_os_iso" {
  for_each     = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  source_file {
    # Schematic ID = df26f4951027143b8a7a5a84bdf0612c86bc6a71c2bed875fe101e495f13db8a
    # https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Fqemu-guest-agent&extensions=siderolabs%2Fzfs&platform=nocloud&target=cloud&version=1.7.6
    path      = "https://factory.talos.dev/image/df26f4951027143b8a7a5a84bdf0612c86bc6a71c2bed875fe101e495f13db8a/v1.7.6/nocloud-amd64.iso"
    file_name = "talos-1-7-6.iso"
  }
}
