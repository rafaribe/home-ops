locals {
  iot_devices = [
    {
      name = "Awair Element"
      mac  = "70:88:6b:14:8a:69"
    },
    {
      name = "Yeelight"
      mac  = "78:11:dc:6a:c3:e4"
    }
  ]
  servers = [
    {
      name = "Truenas"
      mac  = "0c:c4:7a:c0:df:0a"
    },
  ]
  access_points = [
    # {
    #   name = "AP - Attic"
    #   mac  = "70:88:6b:14:8a:69"
    # },

    # {
    #   name = "AP - Garage"
    #   mac  = "78:11:dc:6a:c3:e4"
    # },
    {
      name = "AP - Office"
      mac  = "60:22:32:45:86:80"
    },
    {
      name = "AP - Living Room"
      mac  = "60:22:32:45:89:4c"
    },
  ]
}

resource "unifi_device" "access_point" {
  for_each = { for i, device in local.access_points : i => device }
  mac      = each.value.mac
  name     = each.value.name
}
resource "unifi_user" "iot" {
  for_each   = { for i, device in local.iot_devices : i => device }
  mac        = each.value.mac
  name       = each.value.name
  network_id = unifi_network.iot.id
}
