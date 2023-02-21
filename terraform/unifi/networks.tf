locals {
  untrusted_vlan_id = 11
  trusted_vlan_id   = 10
}

resource "unifi_network" "main_network" {
  name          = "home-network"
  purpose       = "corporate"
  subnet        = "10.0.1.1/22"
  vlan_id       = local.trusted_vlan_id
  dhcp_start    = "10.0.3.1"
  dhcp_stop     = "10.0.3.254"
  dhcp_enabled  = true
  domain_name   = "home"
  dhcp_dns      = ["10.0.1.250", "1.1.1.1", "9.9.9.9", "8.8.8.8"]
}
