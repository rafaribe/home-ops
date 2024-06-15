module "oidc" {

    source = "./oidc"

    providers = {
      authentik.oidc = authentik.setup
     }

    for_each = { for each in var.oidc : each.authentik_oidc_application_name => each }

    authentik_oidc_application_name     = each.value.authentik_oidc_application_name
    authentik_oidc_application_group    = each.value.authentik_oidc_application_group
    authentik_oidc_application_icon_url = each.value.authentik_oidc_application_icon_url

}

module "proxy" {

    source = "./proxy"

    providers = {
      authentik.proxy = authentik.setup
     }

    for_each = { for each in var.proxy : each.authentik_proxy_application_name => each }

    authentik_proxy_application_name      = each.value.authentik_proxy_application_name
    authentik_proxy_application_group     = each.value.authentik_proxy_application_group
    authentik_proxy_application_icon_url  = each.value.authentik_proxy_application_icon_url
    authentik_proxy_external_host         = each.value.authentik_proxy_external_host

}
