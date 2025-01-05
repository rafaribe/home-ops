output "client_id" {
  sensitive = true
  value     = random_id.this.dec
}

output "client_secret" {
  sensitive = true
  value     = random_password.this.result
}
