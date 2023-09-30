# Allow Terraform
resource "cloudflare_filter" "terraformcloud" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Allow Requests from Terraform Cloud"
  expression  = "(http.user_agent contains \"terraform\")"
}

resource "cloudflare_firewall_rule" "terraform" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Allow Requests from Terraform Cloud"
  filter_id   = cloudflare_filter.terraformcloud.id
  action      = "allow"
}

# Block Not Portugal

resource "cloudflare_filter" "notportugal" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Block Requests that dont come from Portugal and France"
  expression  = "(ip.geoip.country ne \"PT\") or (ip.geoip.country eq \"FR\")"
}

resource "cloudflare_firewall_rule" "notportugal" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Block Requests that don't come from Portugal"
  filter_id   = cloudflare_filter.notportugal.id
  action      = "block"
}
