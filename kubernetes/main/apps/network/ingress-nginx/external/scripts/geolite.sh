#!/bin/sh
set -e

# Install necessary dependencies
apk add --no-cache curl jq

echo 'Fetching latest release from GitHub'

# Get the latest release response from GitHub API
RESPONSE=$(curl -s https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest)

# Extract the release tag name
RELEASE=$(echo $RESPONSE | jq -r '.tag_name')

# Check if the release tag is found
if [ -z "$RELEASE" ]; then
  echo 'Failed to fetch release name!' && exit 1
fi

echo "Latest release fetched: $RELEASE"

# Base URL for the release
BASE_URL="https://github.com/P3TERX/GeoLite.mmdb/releases/download/${RELEASE}"

# Download the GeoLite2 files
echo "Downloading GeoLite2-ASN.mmdb"
curl -L ${BASE_URL}/GeoLite2-ASN.mmdb -o ./GeoLite2-ASN.mmdb

echo "Downloading GeoLite2-City.mmdb"
curl -L ${BASE_URL}/GeoLite2-City.mmdb -o ./GeoLite2-City.mmdb

echo "Downloading GeoLite2-Country.mmdb"
curl -L ${BASE_URL}/GeoLite2-Country.mmdb -o ./GeoLite2-Country.mmdb
