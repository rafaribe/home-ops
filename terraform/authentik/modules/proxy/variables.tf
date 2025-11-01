variable "authentik_proxy_application_name" {
  type        = string
  description = "Authentik OIDC Application Name"
}

variable "authentik_proxy_external_host" {
  type        = string
  description = "Authentik Proxy External Host"
}

variable "authentik_proxy_application_icon_url" {
  type        = string
  description = "Authentik Proxy Icon URL"
}
variable "authentik_proxy_application_group" {
  type        = string
  description = "Application Group"
  default     = "Proxy"
}
variable "authentik_proxy_application_description" {
  type        = string
  description = "Application Description"
  default     = "This is an Proxy Provider for the application"
}
