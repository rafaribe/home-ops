resource "talos_machine_secrets" "machine_secrets" {}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  count                       = 1
  node                        = var.talos_cp_01_ip_addr
  config_patches = [
    yamlencode({
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
        allowSchedulingOnMasters = true
      }
    })
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}
