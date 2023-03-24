output "client_id" {
  sensitive = true
  value     = random_id.random_client_id.dec
}

output "client_secret" {
  sensitive = true
  value     = random_password.random_client_secret.result
}
