output "oidc_client_ids" {
    description = "OIDC Client ID's"
    value = values(module.oidc)[*].client_id
}

output "oidc_client_secrets" {
    description = "OIDC Client Secrets"
    value = values(module.oidc)[*].client_secret
}

output "proxy_providers_id" {
    description = "Proxy Provider ID's"
    value = values(module.proxy)[*].proxy_provider_id
}
