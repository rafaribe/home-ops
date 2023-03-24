locals {
  authentik_domain_proxy_external_url = nonsensitive(data.doppler_secrets.this.map.TF_EXTERNAL_URL)
  authentik_api_token                 = nonsensitive(data.doppler_secrets.this.map.TF_API_TOKEN)
  skovald_kubeconfig                  = nonsensitive(data.doppler_secrets.this.map.TF_KUBECONFIG)
  outpost_config                      = nonsensitive(data.doppler_secrets.this.map.TF_OUTPOST_CONFIG)
}
