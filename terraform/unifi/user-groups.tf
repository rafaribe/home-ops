resource "unifi_user_group" "wifi" {
  name = "wifi"
  site = "Default"
  #qos_rate_max_down = 2000 # 2mbps
  #qos_rate_max_up   = 10   # 10kbps
}
