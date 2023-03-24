module "ils-dev" {

  source                      = "./setup"
  authentik_application_group = "skovald"
  authentik_external_host     = "rafaribe.com"
  authentik_api_token         = var.authentik_api_token
  authentik_api_url           = var.authentik_api_url
  authentik_kubeconfig        = var.authentik_ils_dev_kubeconfig
  authentik_outpost_config    = var.authentik_outpost_config

  oidc = [
    {
      authentik_oidc_application_name     = "grafana-skovald"
      authentik_oidc_application_group    = "skovald"
      authentik_oidc_application_icon_url = "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/grafana-icon.png"
    },
  ]

  proxy = [

    {
      authentik_proxy_application_name     = "kubernetes-dashboard"
      authentik_proxy_application_group    = "ils-dev"
      authentik_proxy_application_icon_url = "https://kubernetes.io/images/favicon.png"
      authentik_proxy_external_host        = "kubernetes.rafaribe.com"
    },

  ]

}
