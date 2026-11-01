#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
docker network inspect safeboard >/dev/null 2>&1 || docker network create safeboard >/dev/null
docker compose -p own-app -f compose.app.yml up -d --build --wait
