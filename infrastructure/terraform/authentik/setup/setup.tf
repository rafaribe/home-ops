module "apps" {

  source = "./apps"

  providers = {
    authentik.setup = authentik
  }

  oidc = var.oidc

  proxy = var.proxy

}

# module "outpost" {

#   source = "./outpost"

#   providers = {
#     authentik.setup = authentik
#   }

#   authentik_proxy_provider_ids = module.apps.proxy_providers_id

#   authentik_application_group = local.group

#   authentik_kubeconfig     = var.authentik_kubeconfig
#   authentik_outpost_config = var.authentik_outpost_config

# }
