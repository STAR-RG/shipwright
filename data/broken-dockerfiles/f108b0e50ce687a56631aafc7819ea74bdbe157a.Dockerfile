FROM debian:buster-slim

ARG PACKAGE_VERSION="=1.17.10-1sb+111g+buster1"
ARG PACKAGE_REPO="https://mirrors.xtom.com/sb/nginx"

RUN buildDeps='gnupg'; \
    set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gettext-base $buildDeps; \
    apt-key adv --fetch-keys "$PACKAGE_REPO/public.key"; \
    echo "deb $PACKAGE_REPO buster main" > /etc/apt/sources.list.d/sb-nginx.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends "nginx$PACKAGE_VERSION"; \
    apt-get purge -y --auto-remove $buildDeps; \
    rm -rf /var/lib/apt/lists/*; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY docker-nginx-*.sh docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
