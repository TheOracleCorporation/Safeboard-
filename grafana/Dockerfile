FROM alpine:3.20
RUN apk add --no-cache curl jq
COPY configure.sh /configure.sh
COPY dashboards /dashboards
ENTRYPOINT ["sh", "/configure.sh"]
