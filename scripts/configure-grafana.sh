#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
docker compose -p own-mon -f compose.monitoring.yml --profile configure run --rm --build grafana-configurator
