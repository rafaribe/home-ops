locals {
  dhcp_dns     = ["10.0.1.250", "1.1.1.1", "9.9.9.9", "8.8.8.8"]
  domain_name  = "home"
  purpose      = "corporate"
  dhcp_enabled = true
  iot_vlan     = 40
  servers_vlan = 15
  guest_vlan   = 20
}

resource "unifi_network" "default" {
  name    = "home-network"
  purpose = local.purpose
  subnet  = "10.0.1.0/24"
  # vlan_id      = local.trusted_vlan_id
  dhcp_start   = "10.0.1.15"
  dhcp_stop    = "10.0.1.239"
  dhcp_enabled = local.dhcp_enabled
  domain_name  = local.domain_name
  dhcp_dns     = local.dhcp_dns
}

resource "unifi_network" "iot" {
  name         = "iot"
  purpose      = local.purpose
  subnet       = "10.0.4.0/24"
  vlan_id      = local.iot_vlan
  dhcp_start   = "10.0.4.2"
  dhcp_stop    = "10.0.4.254"
  dhcp_enabled = local.dhcp_enabled
  domain_name  = local.domain_name
  dhcp_dns     = local.dhcp_dns
}
resource "unifi_network" "guest" {
  name         = "guest"
  purpose      = "corporate"
  subnet       = "10.0.3.0/24"
  vlan_id      = local.guest_vlan
  dhcp_start   = "10.0.3.2"
  dhcp_stop    = "10.0.3.254"
  dhcp_enabled = local.dhcp_enabled
  domain_name  = local.domain_name
  dhcp_dns     = local.dhcp_dns
}

