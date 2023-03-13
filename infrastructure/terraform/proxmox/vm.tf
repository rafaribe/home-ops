module "talos1" {
  source      = "./talos"
  name        = "talos-1"
  node_name   = "odin"
  cpu         = 8
  memory      = 14000
  disk_size   = 16
  iso_id      = proxmox_virtual_environment_file.talos_iso["odin"].id
  vm_id       = 6001
  mac_address = "42:C3:B0:6B:80:E0"
  providers = {
    doppler = doppler
    proxmox = proxmox
  }
}

module "talos2" {
  source      = "./talos"
  name        = "talos-2"
  node_name   = "loki"
  cpu         = 4
  memory      = 12000
  disk_size   = 16
  iso_id      = proxmox_virtual_environment_file.talos_iso["loki"].id
  vm_id       = 6002
  mac_address = "42:D7:7A:D7:89:ED"
  providers = {
    doppler = doppler
    proxmox = proxmox
  }
}

module "talos3" {
  source      = "./talos"
  name        = "talos-3"
  node_name   = "freya"
  cpu         = 4
  memory      = 12000
  disk_size   = 16
  iso_id      = proxmox_virtual_environment_file.talos_iso["freya"].id
  vm_id       = 6003
  mac_address = "86:D0:5F:F2:92:78"
  providers = {
    doppler = doppler
    proxmox = proxmox
  }
}
module "talos4" {
  source      = "./talos"
  name        = "talos-4"
  node_name   = "thor"
  cpu         = 4
  memory      = 12000
  disk_size   = 16
  iso_id      = proxmox_virtual_environment_file.talos_iso["thor"].id
  vm_id       = 6004
  mac_address = "5A:EC:9A:72:75:68"
  providers = {
    doppler = doppler
    proxmox = proxmox
  }
}
