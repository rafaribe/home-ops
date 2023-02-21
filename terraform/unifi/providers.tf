# Configure the Doppler provider with the token
provider "doppler" {
  doppler_token = var.doppler_token
}
# Use a service token that only has access to the unifi project
data "doppler_secrets" "this" {}


# Inject secrets from doppler into Unifi Provider
provider "unifi" {
  username       = nonsensitive(data.doppler_secrets.this.map.UNIFI_USERNAME)
  password       = nonsensitive(data.doppler_secrets.this.map.UNIFI_PASSWORD)
  api_url        = "https://unifi.networking.svc.cluster.local:8443"
  allow_insecure = false
}
