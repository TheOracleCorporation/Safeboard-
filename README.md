# Мониторинг Uptime Kuma на Docker Compose

Учебный проект: Uptime Kuma с базой MariaDB и стенд наблюдения на Prometheus и Grafana.

## Что внутри

| Слой | Сервисы | Файл |
|---|---|---|
| Приложение | Uptime Kuma, MariaDB | `compose.app.yml` |
| Наблюдение | Prometheus, Grafana, mysqld-exporter, blackbox-exporter, node-exporter, cAdvisor | `compose.monitoring.yml` |

Оба слоя работают в одной docker-сети `safeboard` и видят друг друга по именам сервисов.

## Запуск

Нужен Docker (Docker Desktop или Docker Engine).

    sh scripts/deploy-app.sh
    sh scripts/deploy-monitoring.sh
    sh scripts/configure-grafana.sh

Последний скрипт создаёт в Grafana источник данных Prometheus и загружает дашборд из `grafana/dashboards/health.json`.

## Адреса

| Сервис | URL | Доступ |
|---|---|---|
| Uptime Kuma | http://localhost:3001 | при первом входе создайте администратора |
| Grafana | http://localhost:3000 | admin / grafanapass |
| Prometheus | http://localhost:9090/targets | все цели должны быть UP |

## Что показывает дашборд

- Три индикатора: общий статус, MariaDB, Uptime Kuma (зелёный или красный).
- CPU и память хоста, память контейнеров.

Метрики для индикаторов:
- `mysql_up`: видит ли экспортёр живую базу;
- `probe_success`: открывается ли страница Uptime Kuma (проверяет blackbox-exporter).

## Проверка отказа

    docker compose -p own-app -f compose.app.yml stop kuma    # индикатор Kuma краснеет
    docker compose -p own-app -f compose.app.yml start kuma   # через ~30 секунд снова зелёный

## Остановка

    docker compose -p own-mon -f compose.monitoring.yml down -v
    docker compose -p own-app -f compose.app.yml down -v
    docker network rm safeboard

## Ограничения

- Пароли в файлах демонстрационные, для локального стенда. Для реального использования их нужно вынести в `.env`.
- На Docker Desktop с включённым containerd image store cAdvisor не подписывает контейнеры именами, поэтому на графике памяти контейнеров они показаны коротким ID (сопоставление: `docker ps --format '{{.ID}} {{.Names}}'`).
- На macOS node-exporter показывает ресурсы виртуальной машины Docker Desktop, а не самого Mac.
