locals {
  boot_order = var.network_boot ? ["net0", "scsi0"] : ["scsi0", "ide3", "net0"]
  cdrom_config = var.network_boot ? { enabled = false } : {
    enabled = true
    file_id = var.iso_id
  }
}
