# Access the secret value
output "service_tokens" {
  value = { for env, token in doppler_service_token.service_token : env => token.key  }
}
