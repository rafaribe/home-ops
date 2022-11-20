variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}
variable "cloudflare_email" {
  type        = string
  description = "Cloudflare Email Address"
}
variable "cloudflare_apikey" {
  type        = string
  description = "Cloudflare Account API Key"
}
variable "cloudflare_domain_com" {
  type        = string
  description = "My .com domain"
}
variable "cloudflare_public_cname_domain_com" {
  type        = string
  description = "Public CNAME that do not proxy thru Cloudflare"
}
