#!/bin/sh
set -e

# Install necessary dependencies
#apk add --no-cache curl jq

echo 'Fetching latest release from GitHub'

# Get the latest release response from GitHub API
RESPONSE=$(curl -s https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest)

# Extract the release tag name
RELEASE=$(echo $RESPONSE | jq -r '.tag_name')

# Check if RELEASE is empty or 'null', and set it to the current date if necessary
if [ "$RELEASE" = "null" ] || [ -z "$RELEASE" ]; then
  echo "No release found or release tag is null, using current date as version"
  RELEASE=$(date +'%Y.%m.%d')  # Get the current date in YYYY.MM.DD format
fi

echo "Using release: $RELEASE"

# Base URL for the release
BASE_URL="https://github.com/P3TERX/GeoLite.mmdb/releases/download/${RELEASE}"
BASE_DIR=/home
# Download the GeoLite2 files
echo "Downloading GeoLite2-ASN.mmdb"
curl -L ${BASE_URL}/GeoLite2-ASN.mmdb -o ${BASE_DIR}/GeoLite2-ASN.mmdb

echo "Downloading GeoLite2-City.mmdb"
curl -L ${BASE_URL}/GeoLite2-City.mmdb -o ${BASE_DIR}/GeoLite2-City.mmdb

echo "Downloading GeoLite2-Country.mmdb"
curl -L ${BASE_URL}/GeoLite2-Country.mmdb -o ${BASE_DIR}/GeoLite2-Country.mmdb
