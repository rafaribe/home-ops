# Access the secret value
output "service_tokens" {
  value = { for env in toset(var.environments) :
    env => {
      key         = doppler_service_token.service_token[env].key
      environment = env
    }
  }
  sensitive = false
}
