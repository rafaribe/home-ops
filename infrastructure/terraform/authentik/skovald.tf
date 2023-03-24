module "skovald" {

  source                      = "./setup"
  authentik_application_group = "skovald"
  authentik_external_host     = "rafaribe.com"
  authentik_api_token         = local.authentik_api_token
  authentik_api_url           = local.authentik_domain_proxy_external_url
  authentik_kubeconfig        = local.skovald_kubeconfig
  authentik_outpost_config    = local.outpost_config

  oidc = [
    {
      authentik_oidc_application_name     = "grafana"
      authentik_oidc_application_group    = "skovald"
      authentik_oidc_application_icon_url = "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/grafana-icon.png"
    },
  ]

  proxy = [

    {
      authentik_proxy_application_name     = "kubernetes-dashboard"
      authentik_proxy_application_group    = "skovald"
      authentik_proxy_application_icon_url = "https://kubernetes.io/images/favicon.png"
      authentik_proxy_external_host        = "https://kubernetes.rafaribe.com"
    },

  ]
  providers = {
    authentik = authentik
  }

}
