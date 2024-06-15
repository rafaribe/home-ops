variable "gitlab_consumer_key" {
  type = string
}

variable "gitlab_consumer_secret" {
  type = string
}


variable "authentik_api_token" {
  type        = string
  description = "Authentik API Token"
}

variable "authentik_api_url" {
  type        = string
  description = "Authentik API URL"
}
