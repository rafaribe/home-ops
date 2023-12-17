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
  doppler_token = data.terraform_remote_state.doppler_provider.outputs.all_service_tokens.minio.prod.key
}
# Use a service token that only has access to the unifi project
data "doppler_secrets" "this" {}


# Inject secrets from doppler into Minio Provider
provider "minio" {
  minio_server   = nonsensitive(data.doppler_secrets.this.map.MINIO_SERVER)
  minio_user     = nonsensitive(data.doppler_secrets.this.map.MINIO_USER)
  minio_password = nonsensitive(data.doppler_secrets.this.map.MINIO_PASSWORD)
}

