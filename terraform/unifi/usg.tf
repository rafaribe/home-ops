resource "unifi_setting_usg" "usg_settings" {
  multicast_dns_enabled = true
  site                  = unifi_site.default.name
}
