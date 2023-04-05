resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


resource "proxmox_virtual_environment_vm" "talos" {
  name        = var.name
  description = "Managed by Terraform"
  tags        = ["terraform", "k3s", "kubernetes"]

  node_name = var.node_name
  vm_id     = var.vm_id
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 60
    file_format  = "qcow2"
  }
  cpu {
    cores   = var.cpu
    sockets = 1
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

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = var.password
      username = "brr"
    }

    # user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }
  keyboard_layout = "pt"


  serial_device {}
  lifecycle {
    ignore_changes = [tags]
  }
}
