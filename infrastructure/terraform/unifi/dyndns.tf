resource "unifi_dynamic_dns" "duck_dns" {
  service = "dyndns"

  host_name = nonsensitive(data.doppler_secrets.this.map.DYNDNS_HOST)
  server    = "www.duckdns.org"
  login     = nonsensitive(data.doppler_secrets.this.map.DYNDNS_USER)
  password  = nonsensitive(data.doppler_secrets.this.map.DYNDNS_TOKEN)
}
