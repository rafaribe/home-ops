variable "authentik_proxy_provider_ids" {
  type        = list(string)
  description = "List of Proxy Providers ID's"
}

variable "authentik_application_group" {
  type        = string
  description = "What project/environment this kubeconfig belong to"
}

variable "authentik_kubeconfig" {
  type        = string
  description = "Kubeconfig config"
}

variable "authentik_outpost_config" {
  type        = string
  description = "Outpost config"
}
