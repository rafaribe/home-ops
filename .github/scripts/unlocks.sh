#!/bin/bash

# Define the list of commands
commands=(
    "task volsync:unlock cluster=main ns=ai app=ollama"
    "task volsync:unlock cluster=main ns=ai app=open-webui"
    "task volsync:unlock cluster=main ns=ai app=paperless-ai"
    "task volsync:unlock cluster=main ns=downloads app=bazarr"
    "task volsync:unlock cluster=main ns=downloads app=kapowarr"
    "task volsync:unlock cluster=main ns=downloads app=lidarr"
    "task volsync:unlock cluster=main ns=downloads app=metube"
    "task volsync:unlock cluster=main ns=downloads app=prowlarr"
    "task volsync:unlock cluster=main ns=downloads app=qbittorrent"
    "task volsync:unlock cluster=main ns=downloads app=radarr"
    "task volsync:unlock cluster=main ns=downloads app=readarr"
    "task volsync:unlock cluster=main ns=downloads app=recyclarr"
    "task volsync:unlock cluster=main ns=downloads app=sabnzbd"
    "task volsync:unlock cluster=main ns=downloads app=sonarr"
    "task volsync:unlock cluster=main ns=home app=home-assistant"
    "task volsync:unlock cluster=main ns=home app=node-red"
    "task volsync:unlock cluster=main ns=media app=audiobookshelf"
    "task volsync:unlock cluster=main ns=media app=calibre-web"
    "task volsync:unlock cluster=main ns=media app=jellyfin"
    "task volsync:unlock cluster=main ns=media app=jellyseerr"
    "task volsync:unlock cluster=main ns=media app=kavita"
    "task volsync:unlock cluster=main ns=media app=kometa"
    "task volsync:unlock cluster=main ns=media app=komga"
    "task volsync:unlock cluster=main ns=media app=maintainerr"
    "task volsync:unlock cluster=main ns=media app=media-browser"
    "task volsync:unlock cluster=main ns=media app=navidrome"
    "task volsync:unlock cluster=main ns=media app=plex"
    "task volsync:unlock cluster=main ns=media app=tautulli"
    "task volsync:unlock cluster=main ns=media app=wizarr"
    "task volsync:unlock cluster=main ns=media app=your-spotify"
    "task volsync:unlock cluster=main ns=observability app=redisinsight"
    "task volsync:unlock cluster=main ns=services app=actual"
    "task volsync:unlock cluster=main ns=services app=bytestash"
    "task volsync:unlock cluster=main ns=services app=hoarder"
    "task volsync:unlock cluster=main ns=services app=kitchenowl"
    "task volsync:unlock cluster=main ns=services app=lubelog"
    "task volsync:unlock cluster=main ns=services app=mealie"
    "task volsync:unlock cluster=main ns=services app=n8n"
    "task volsync:unlock cluster=main ns=services app=netboot"
    "task volsync:unlock cluster=main ns=services app=paperless"
    "task volsync:unlock cluster=main ns=services app=pinchflat"
    "task volsync:unlock cluster=main ns=services app=postiz"
    "task volsync:unlock cluster=main ns=services app=radicale"
    "task volsync:unlock cluster=main ns=services app=silverbullet"
    "task volsync:unlock cluster=main ns=services app=stirling-pdf"
    "task volsync:unlock cluster=main ns=services app=tandoor"
    "task volsync:unlock cluster=main ns=services app=thelounge"
    "task volsync:unlock cluster=main ns=services app=vikunja"
    "task volsync:unlock cluster=main ns=storage app=pgadmin"
    "task volsync:unlock cluster=main ns=storage app=syncthing"
)

# Run each command in parallel
for cmd in "${commands[@]}"; do
    eval "$cmd" &
done

# Wait for all background processes to finish
wait

echo "All tasks completed."
