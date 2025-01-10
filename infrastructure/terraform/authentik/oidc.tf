locals {
  oidcs = [
    {
      authentik_oidc_application_name        = "grafana"
      authentik_oidc_application_icon_url    = "https://w1.pngwing.com/pngs/950/813/png-transparent-github-logo-grafana-influxdb-dashboard-visualization-web-application-installation-data-plugin-thumbnail.png"
      authentik_oidc_application_description = "Grafana OAuth application"
    },
    {
      authentik_oidc_application_name        = "paperless"
      authentik_oidc_application_icon_url    = "https://avatars.githubusercontent.com/u/99562962?s=280&v=4"
      authentik_oidc_application_description = "Paperless OAuth application"
    },
    {
      authentik_oidc_application_name        = "pgadmin"
      authentik_oidc_application_icon_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Postgresql_elephant.svg/1200px-Postgresql_elephant.svg.png"
      authentik_oidc_application_description = "PGAdmin OAuth application"
    },
    {
      authentik_oidc_application_name        = "gotosocial"
      authentik_oidc_application_icon_url    = "https://raw.githubusercontent.com/superseriousbusiness/gotosocial/main/docs/overrides/public/sloth.webp"
      authentik_oidc_application_description = "Fediverse"
    },
    {
      authentik_oidc_application_name        = "windmill"
      authentik_oidc_application_icon_url    = "https://avatars.githubusercontent.com/u/98025271?s=200&v=4"
      authentik_oidc_application_description = "OSS developer platform to build multistep automations and internal apps from minimal Typescript and Python scripts"
    }
  ]
}

module "oidc" {

  for_each = { for oidc in local.oidcs : oidc.authentik_oidc_application_name => oidc }

  source = "./modules/oidc"

  providers = {
    authentik = authentik
  }

  authentik_oidc_application_name        = each.value.authentik_oidc_application_name
  authentik_oidc_application_icon_url    = each.value.authentik_oidc_application_icon_url
  authentik_oidc_application_description = each.value.authentik_oidc_application_description
}
