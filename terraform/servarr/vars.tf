variable "local_domain" {
  type        = string
  default     = "rafaribe.com"
  description = "Proxy Address"
}

variable "cluster_downloads_domain" {
  type        = string
  default     = "downloads.svc.cluster.local"
  description = "Cluster Downloads Namespace Domain"
}

variable "ports" {
  type = map(string)
  default = {
    "sonarr"      = "80"
    "prowlarr"    = "80"
    "radarr"      = "80"
    "sabnzbd"     = "8080"
    "qbittorrent" = "80"
  }
  description = "Mapping of services to their respective ports"
}
