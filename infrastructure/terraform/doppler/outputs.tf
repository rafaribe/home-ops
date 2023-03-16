# We need this data source for the remote terraform state file

output "all_service_tokens" {
  value = {
    for module_name, module_outputs in {
      "cert-manager"  = module.cert-manager.service_tokens
      "cloudflare"    = module.cloudflare.service_tokens
      "authentik"     = module.authentik.service_tokens
      "unifi"         = module.unifi.service_tokens
      "flux"          = module.flux.service_tokens
      "tfcontroller"  = module.tfcontroller.service_tokens
      "proxmox"       = module.proxmox.service_tokens
      "cloudnativepg" = module.cloudnativepg.service_tokens
    } :
    module_name => module_outputs
  }
  sensitive = true
}
