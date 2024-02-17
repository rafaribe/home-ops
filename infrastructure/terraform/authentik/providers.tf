
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
  doppler_token = data.terraform_remote_state.doppler_provider.outputs.all_service_tokens.authentik.prod.key
}
# Use a service token that only has access to the unifi project
data "doppler_secrets" "this" {}


# Inject secrets from doppler into Unifi Provider

provider "authentik" {
  url      = nonsensitive(data.doppler_secrets.this.map.TF_API_URL)
  token    = nonsensitive(data.doppler_secrets.this.map.TF_API_TOKEN)
  insecure = true
}
