resource "unifi_wlan" "brrcft" {
  name       = "BRRCFT"
  passphrase = nonsensitive(data.doppler_secrets.this.map.WIFI_PASSWORD)
  security   = "wpapsk"

  # enable WPA2/WPA3 support
  wpa3_support      = true
  wpa3_transition   = true
  pmf_mode          = "optional"
  no2ghz_oui        = true
  network_id        = unifi_network.default.id
  ap_group_ids      = [data.unifi_ap_group.default.id]
  user_group_id     = unifi_user_group.wifi.id
  wlan_band         = "both"
  multicast_enhance = true
}
