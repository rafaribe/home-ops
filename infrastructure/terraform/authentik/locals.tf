locals {
  authentik_domain_proxy_external_url = nonsensitive(data.doppler_secrets.this.map.EXTERNAL_URL)
}
