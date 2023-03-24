locals {
  authentik_domain_proxy_external_url = data.doppler_secrets.this.map.EXTERNAL_URL
}
