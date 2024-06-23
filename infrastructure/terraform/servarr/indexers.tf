resource "prowlarr_indexer" "usenet_nzbgeek" {
  enable          = true
  name            = "NZBGeek"
  implementation  = "Newznab"
  config_contract = "NewznabSettings"
  app_profile_id  = 1
  protocol        = "usenet"
  priority        = 1
  tags            = []

  fields = [
    {
      name: "baseUrl",
      text_value: "https://api.nzbgeek.info"
    },
    {
      name: "apiPath"
      text_value: "/api"
    },
    {
      name: "apiKey"
      text_value: "${data.sops_file.servarr-secrets.data["nzbgeek_api_key"]}"
    },
    {
      name: "vipExpiration"
      text_value: "2024-04-01"
    }
  ]
}

resource "prowlarr_indexer" "example" {
  enable          = true
  name            = "MyAnonaMouse"
  implementation  = "MyAnonaMouse"
  config_contract = "MyAnonaMouseSettings"
  protocol        = "torrent"
  app_profile_id  = 2
  tags            = []

  fields = [
    {
      name       = "mamId"
      text_value = "${data.sops_file.servarr-secrets.data["prowlarr_mam_id"]}"
    },    {
      name         = "torrentBaseSettings.seedRatio"
      number_value = 0.5
    },
    {
      name         = "torrentBaseSettings.seedTime"
      number_value = 5
    },
  ]
}
