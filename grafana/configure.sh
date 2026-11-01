#!/bin/sh
set -eu
AUTH="${GF_USER}:${GF_PASS}"

echo "ждём Grafana..."
i=0
until curl -fs "$GF_URL/api/health" >/dev/null 2>&1; do
  i=$((i+1)); [ "$i" -gt 60 ] && { echo "Grafana не отвечает"; exit 1; }
  sleep 2
done

echo "источник данных Prometheus"
code=$(curl -s -o /dev/null -w '%{http_code}' -u "$AUTH" \
  -H 'Content-Type: application/json' -X POST "$GF_URL/api/datasources" \
  -d '{"name":"prometheus","uid":"prometheus","type":"prometheus","access":"proxy","url":"http://prometheus:9090","isDefault":true}')
case "$code" in
  200|409) echo "  http $code (создан или уже существует)";;
  *) echo "  ошибка, http $code"; exit 1;;
esac

for f in /dashboards/*.json; do
  echo "дашборд $f"
  jq '(.. | select(type=="object" and ((.datasource|type)=="object") and .datasource.type=="prometheus") | .datasource.uid) |= "prometheus"
      | {dashboard: (. + {id: null}), overwrite: true}' "$f" \
    | curl -fsS -u "$AUTH" -H 'Content-Type: application/json' \
        -X POST "$GF_URL/api/dashboards/db" -d @-
  echo
done
echo "готово"
