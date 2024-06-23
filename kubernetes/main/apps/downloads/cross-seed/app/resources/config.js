module.exports = {
  delay: 20,
  qbittorrentUrl: "http://qbittorrent.downloads.svc.cluster.local:8080",
  torznab: [
    `http://prowlarr.media.svc.cluster.local:9696/5/api?apikey=$${process.env.PROWLARR_API_KEY}`,
    `http://prowlarr.media.svc.cluster.local:9696/6/api?apikey=$${process.env.PROWLARR_API_KEY}`,
    `http://prowlarr.media.svc.cluster.local:9696/13/api?apikey=$${process.env.PROWLARR_API_KEY}`,
    `http://prowlarr.media.svc.cluster.local:9696/15/api?apikey=$${process.env.PROWLARR_API_KEY}`,
    `http://prowlarr.media.svc.cluster.local:9696/18/api?apikey=$${process.env.PROWLARR_API_KEY}`,
    `http://prowlarr.media.svc.cluster.local:9696/16/api?apikey=$${process.env.PROWLARR_API_KEY}`,
  ],
  port: process.env.CROSSSEED_PORT || 2468,
  apiAuth: false,
  action: "inject",
  includeEpisodes: false,
  includeSingleEpisodes: true,
  includeNonVideos: true,
  duplicateCategories: true,
  matchMode: "safe",
  skipRecheck: true,
  outputDir: "/config",
  torrentDir: "/qbittorrent/qBittorrent/BT_backup",
}
