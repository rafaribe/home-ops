variable "doppler_token" {
  type        = string
  description = "Doppler API Token"
}
variable "project-name" {
  type        = string
  description = "Doppler Project name"
}

variable "environments" {
  type        = list(string)
  description = "Doppler environments to create"
  default     = ["prod"]
}

