resource "proxmox_virtual_environment_vm" "virtualmachine" {
  name        = var.name
  description = "Managed by Terraform"
  tags        = var.tags

  node_name       = var.node_name
  vm_id           = var.vm_id
  keyboard_layout = "pt"
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_size
    file_format  = "raw"
  }

  dynamic "disk" {
    for_each = var.additional_disk != null ? { 0 = var.additional_disk } : {}
    content {
      datastore_id = disk.value[0].datastore_id
      file_format  = disk.value[0].file_format
      size         = disk.value[0].size
      interface    = "scsi1"
    }
  }

  cpu {
    cores   = var.cpu
    sockets = var.sockets
    type    = "host"
  }
  memory {
    dedicated = var.memory
  }
  cdrom {
    enabled = local.cdrom_config.enabled
    file_id = lookup(local.cdrom_config, "file_id", null)
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.mac_address
  }

  operating_system {
    type = "l26"
  }


  boot_order = local.boot_order
  agent {
    enabled = var.agent
  }

  serial_device {}
  lifecycle {
    ignore_changes = [tags, started]
  }
}
