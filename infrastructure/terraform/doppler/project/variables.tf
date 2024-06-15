
variable "project_name" {
  type        = string
  description = "Doppler Project name"
}
variable "project_description" {
  type        = string
  description = "Doppler Project Description"
  default     = ""
}
variable "environments" {
  type        = list(string)
  description = "Doppler environments to create"
  default     = ["prod"]
}
