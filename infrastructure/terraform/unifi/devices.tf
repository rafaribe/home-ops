locals {
  iot_devices = [
    {
      name = "Awair Element"
      mac  = "70:88:6b:14:8a:69"
    },
    {
      name = "Light - Office"
      mac  = "78:11:dc:6a:c3:e4"
    }
  ]
  servers = [
    {
      name     = "truenas"
      mac      = "0c:c4:7a:c0:df:0a"
      fixed_ip = "10.0.0.6"
      note     = "stable server running truenas scale "
    },
    {
      name     = "odin"
      mac      = "10:c3:7b:1d:d6:f4"
      fixed_ip = "10.0.1.7"
      note     = "Asus Laptop"
    },
    {
      name     = "loki"
      mac      = "18:66:da:3c:a4:86"
      fixed_ip = "10.0.1.8"
      note     = "Dell from the left"
    },

    {
      name     = "freya"
      mac      = "00:1e:06:45:43:3e"
      fixed_ip = "10.0.1.9"
      note     = "Odroid H2+"
    },

    {
      name     = "thor"
      mac      = "e4:a7:a0:7c:81:20"
      fixed_ip = "10.0.1.10"
      note     = "Dell from the right"
    },
    {
      name     = "backup-server"
      mac      = "dc:a6:32:06:d6:0e"
      fixed_ip = "10.0.1.11"
      note     = "Raspberry Pi with 2 External HDD"
    },
    //
    {
      name     = "talos1"
      mac      = "42:C3:B0:6B:80:E0"
      fixed_ip = "10.0.1.12"
      note     = "VM on Odin"
    },
    {
      name     = "talos2"
      mac      = "42:D7:7A:D7:89:ED"
      fixed_ip = "10.0.1.13"
      note     = "VM on Loki"
    },
    {
      name     = "talos3"
      mac      = "86:D0:5F:F2:92:78"
      fixed_ip = "10.0.1.14"
      note     = "VM on Freya"
    },

    {
      name     = "talos4"
      mac      = "5A:EC:9A:72:75:68"
      fixed_ip = "10.0.1.15"
      note     = "VM on Thor"
    },
  ]
  access_points = [
    {
      name = "AP - Garage"
      mac  = "18:e8:29:e0:f0:da"
    },
    {
      name = "AP - Office"
      mac  = "60:22:32:45:86:80"
    },
    {
      name = "AP - Living Room"
      mac  = "18:e8:29:a0:5f:12"
    },
    {
      name = "AP - Attic"
      mac  = "60:22:32:45:89:4c"
    },
  ]
}

resource "unifi_device" "access_point" {
  for_each = { for i, device in local.access_points : i => device }
  mac      = each.value.mac
  name     = each.value.name
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "unifi_user" "iot" {
  for_each   = { for i, device in local.iot_devices : i => device }
  mac        = each.value.mac
  name       = each.value.name
  network_id = unifi_network.iot.id
}

resource "unifi_user" "server" {
  for_each   = { for i, device in local.servers : i => device }
  mac        = each.value.mac
  name       = each.value.name
  network_id = unifi_network.default.id
  fixed_ip   = each.value.fixed_ip
  note       = each.value.note
}
