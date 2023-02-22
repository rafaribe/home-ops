locals {
  untrusted_vlan_id = 11
  trusted_vlan_id   = 10
}

resource "unifi_network" "default" {
  name    = "home-network"
  purpose = "corporate"
  subnet  = "10.0.1.0/24"
  # vlan_id      = local.trusted_vlan_id
  dhcp_start   = "10.0.1.15"
  dhcp_stop    = "10.0.1.240"
  dhcp_enabled = true
  domain_name  = "home"
  dhcp_dns     = ["10.0.1.250", "1.1.1.1", "9.9.9.9", "8.8.8.8"]
}

resource "unifi_network" "iot" {
  name          = "iot"
  purpose       = "corporate"
  subnet        = "10.0.4.0/24"
  vlan_id       = local.untrusted_vlan_id
  dhcp_start    = "10.0.4.2"
  dhcp_stop     = "10.0.4.254"
  dhcp_enabled  = true
  domain_name   = "home"
  dhcp_dns      = ["1.1.1.1", "9.9.9.9", "8.8.8.8"]
  igmp_snooping = true
}

