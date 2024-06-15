
variable "oidc" {
  type = list(object({
    authentik_oidc_application_name     = string
    authentik_oidc_application_group    = string
    authentik_oidc_application_icon_url = string
  }))
}

variable "proxy" {
  type = list(object({
    authentik_proxy_application_name      = string
    authentik_proxy_application_group     = string
    authentik_proxy_application_icon_url  = string
    authentik_proxy_external_host         = string
  }))
}
