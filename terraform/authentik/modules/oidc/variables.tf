variable "authentik_oidc_application_name" {
  type        = string
  description = "Authentik OIDC Application Name"
}

variable "authentik_oidc_application_icon_url" {
  type        = string
  description = "Authentik OIDC Icon URL"
}
variable "authentik_oidc_application_group" {
  type        = string
  description = "Application Group"
  default     = "OIDC"
}
variable "authentik_oidc_application_description" {
  type        = string
  description = "Application Description"
  default     = "This is an OIDC Provider for the application"
}

variable "create_akeyless_secret" {
  type        = bool
  description = "Create secret in akeyless"
  default     = true
}
