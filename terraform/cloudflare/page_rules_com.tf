resource "cloudflare_page_rule" "plex_bypass_cache" {
  zone_id  = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  target   = "jellyfin.${var.cloudflare_domain_com}/*"
  status   = "active"
  priority = 1

  actions {
    cache_level = "bypass"
  }
}

resource "cloudflare_page_rule" "hass_bypass_cache" {
  zone_id  = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  target   = "hass.${var.cloudflare_domain_com}/*"
  status   = "active"
  priority = 2

  actions {
    cache_level = "bypass"
  }
}
