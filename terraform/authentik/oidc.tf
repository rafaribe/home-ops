locals {
  oidcs = [
    {
      authentik_oidc_application_name        = "gotosocial"
      authentik_oidc_application_icon_url    = "https://raw.githubusercontent.com/superseriousbusiness/gotosocial/main/docs/overrides/public/sloth.webp"
      authentik_oidc_application_description = "Fediverse"
    },
    {
      authentik_oidc_application_name        = "grafana"
      authentik_oidc_application_icon_url    = "https://w1.pngwing.com/pngs/950/813/png-transparent-github-logo-grafana-influxdb-dashboard-visualization-web-application-installation-data-plugin-thumbnail.png"
      authentik_oidc_application_description = "Grafana OAuth application"
    },
    {
      authentik_oidc_application_name        = "karakeep"
      authentik_oidc_application_icon_url    = "https://media.invisioncic.com/u329766/monthly_2024_05/hoarder.png.cb75b7347d47989bd0c3e65b9e613700.png"
      authentik_oidc_application_description = "A self-hostable bookmark-everything app (links, notes and images) with AI-based automatic tagging and full text search"
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
      authentik_oidc_application_name        = "tandoor"
      authentik_oidc_application_icon_url    = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXMMZeussUqq5cUvq2G1-o4T_hGIxuOMPkYw&s"
      authentik_oidc_application_description = "Manage your ever growing recipe collection online"
    },
    {
      authentik_oidc_application_name        = "zot"
      authentik_oidc_application_icon_url    = "https://landscape.cncf.io/logos/e247ac93d0f20080fee02573fef04d5b1c5914cf07bbed0cbcd2b9ec1e0419ed.svg"
      authentik_oidc_application_description = "Zot is an OCI-native container registry for distributing container images and OCI artifacts."
    },
    {
      authentik_oidc_application_name        = "filebrowser"
      authentik_oidc_application_icon_url    = "https://i.imgur.com/Z6fTRV3.png"
      authentik_oidc_application_description = "FileBrowser Quantum provides an easy way to access and manage your files from the web"
    },
    {
      authentik_oidc_application_name        = "linkding"
      authentik_oidc_application_icon_url    = "https://res.cloudinary.com/canonical/image/fetch/f_auto,q_auto,fl_sanitize,w_60/https%3A%2F%2Fdashboard.snapcraft.io%2Fsite_media%2Fappmedia%2F2024%2F02%2Fapple-touch-icon.png"
      authentik_oidc_application_description = "Linkding is a self-hosted bookmark manager that is easy to use and deploy."
    },
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
