#!/bin/bash

set -e

items=""

for item in $(grep -v '^#' "$1"); do
  items="$items +workshop_download_item 282440 $item"
done

set -x
"${STEAMCMD}" +login anonymous $items +quit
mkdir -p "${QL}/steamapps"
mv "${HOME}/Steam/steamapps/workshop" "${QL}/steamapps"