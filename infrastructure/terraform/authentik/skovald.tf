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
      authentik_proxy_application_name     = "hubble"
      authentik_proxy_application_group    = "skovald"
      authentik_proxy_application_icon_url = "https://raw.githubusercontent.com/cilium/hubble/9429bbf4b5b504a9b0f6752ccfbb16a2878bb51e/Documentation/images/hubble_logo.png"
      authentik_proxy_external_host        = "https://hubble.rafaribe.com"
    },
    {
      authentik_proxy_application_name     = "thanos"
      authentik_proxy_application_group    = "skovald"
      authentik_proxy_application_icon_url = "https://thanos.io/icon-dark.png"
      authentik_proxy_external_host        = "https://thanos-query-frontend.rafaribe.com"
    },
    {
      authentik_proxy_application_name     = "alertmanager"
      authentik_proxy_application_group    = "skovald"
      authentik_proxy_application_icon_url = "https://luktom.net/wordpress/wp-content/uploads/2019/05/prometheus.png"
      authentik_proxy_external_host        = "https://alertmanager.rafaribe.com"
    },
    {
      authentik_proxy_application_name     = "prometheus"
      authentik_proxy_application_group    = "skovald"
      authentik_proxy_application_icon_url = "https://luktom.net/wordpress/wp-content/uploads/2019/05/prometheus.png"
      authentik_proxy_external_host        = "https://prometheus.rafaribe.com"
    },

  ]
  providers = {
    authentik = authentik
  }

}
