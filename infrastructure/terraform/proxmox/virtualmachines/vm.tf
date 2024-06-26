resource "proxmox_virtual_environment_vm" "virtualmachine" {
  name        = var.name
  description = "Managed by Terraform"
  tags        = var.tags

  node_name = var.node_name
  vm_id     = var.vm_id
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_size
    file_format  = "raw"
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
    enabled = true
    file_id = var.iso_id
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.mac_address
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }


  serial_device {}
  lifecycle {
    ignore_changes = [tags]
  }
}
