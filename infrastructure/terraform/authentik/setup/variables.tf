variable "authentik_application_group" {
  type        = string
  description = "What project/environment these apps belong to"
}

variable "authentik_external_host" {
  type        = string
  description = "The url suffix"
}

variable "authentik_api_token" {
  type        = string
  description = "Authentik API Token"
}

variable "authentik_api_url" {
  type        = string
  description = "Authentik API URL"
}

variable "authentik_kubeconfig" {
  type        = string
  description = "Kubeconfig config"
}

variable "authentik_outpost_config" {
  type        = string
  description = "Outpost config"
}

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
