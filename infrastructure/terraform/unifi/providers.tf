data "terraform_remote_state" "doppler_provider" {
  backend = "remote"

  config = {
    organization = "rafaribe"
    hostname     = "app.terraform.io"

    workspaces = {
      name = "home-doppler"
    }
  }
}

# Configure the Doppler provider with the token
provider "doppler" {
  doppler_token = data.terraform_remote_state.doppler_provider.outputs.all_service_tokens.unifi.prod.key
}
# Use a service token that only has access to the unifi project
data "doppler_secrets" "this" {}


# Inject secrets from doppler into Unifi Provider
provider "unifi" {
  username       = nonsensitive(data.doppler_secrets.this.map.UNIFI_USERNAME)
  password       = nonsensitive(data.doppler_secrets.this.map.UNIFI_PASSWORD)
  api_url        = nonsensitive(data.doppler_secrets.this.map.UNIFI_API_ENDPOINT)
  allow_insecure = true
}
