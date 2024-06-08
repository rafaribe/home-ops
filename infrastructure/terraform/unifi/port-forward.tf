resource "unifi_port_forward" "ipv4_kubernetes" {
  fwd_ip                 = nonsensitive(data.doppler_secrets.this.map.PORT_FORWARD_IP)
  fwd_port               = 443
  name                   = "kubernetes-ingress"
  dst_port               = 443
  port_forward_interface = "wan"
}
resource "unifi_port_forward" "qbittorrent" {
  fwd_ip                 = "10.0.1.3"
  fwd_port               = 50413
  name                   = "qbittorrent"
  dst_port               = 50413
  port_forward_interface = "wan"
}
