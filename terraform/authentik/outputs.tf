locals {
  oidc_applications = {
    for k, v in module.oidc : k => {
      client_id     = v.client_id
      client_secret = v.client_secret
    }
  }
}

output "all_oidc_applications" {
  value     = local.oidc_applications
  sensitive = true
}
