#!/usr/bin/env bash

for id in $(gh run list --limit 5000 --jq ".[] | select (.status == \"queued\" ) | .databaseId" --json databaseId,status); do gh run cancel $id; done
