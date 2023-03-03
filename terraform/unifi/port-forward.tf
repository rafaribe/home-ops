resource "unifi_port_forward" "ipv4_kubernetes" {
  fwd_ip                 = nonsensitive(data.doppler_secrets.this.map.PORT_FORWARD_IP)
  fwd_port               = 443
  name                   = "kubernetes-ingress"
  dst_port               = 443
  enabled                = true
  port_forward_interface = "wan"
}
