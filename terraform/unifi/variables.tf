# Define a variable so we can pass in our token
variable "doppler_token" {
  type        = string
  description = "A token to authenticate with Doppler"
}
variable "unifi_api_url" {
  type        = string
  description = "The url for the unifi API"
}
