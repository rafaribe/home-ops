

// Manually ran to passthrough disk:
// qm set 6001 -scsi2 /dev/disk/by-id/ata-HGST_HTS721075A9E630_JR12006QG0YW5E

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
// Manually ran to passthrough disk:
// qm set 6002 -scsi1 /dev/disk/by-id/usb-WD_Elements_25A3_4341304D5032454B-0:0
// qm set 6002 -scsi2 /dev/disk/by-id/usb-Realtek_RTL9210_NVME_012345678904-0:0
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

// Manually ran to passthrough disk:
// qm set 6003 -scsi1 /dev/disk/by-id/usb-WD_My_Passport_25E2_575836314441373641485943-0:0

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


// Manually ran to passthrough disk:
// qm set 6004 -scsi1 /dev/disk/by-id/usb-SanDisk_Extreme_55AE_32323039444E343033313735-0:0
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
