
FROM alpine:3.10 as stage1

# hadolint ignore=DL3018
RUN \
  apk update  --quiet --no-cache

# hadolint ignore=DL3018
RUN \
  apk add     --quiet --no-cache \
    build-base \
    ca-certificates \
    curl \
    php7-dev \
    php7-fpm \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fpm \
    php7-gettext \
    php7-gd \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-openssl \
    php7-pdo_mysql \
    php7-pear \
    php7-phar \
    php7-session \
    php7-simplexml \
    php7-tokenizer \
    php7-xml \
    yaml \
    yaml-dev

# patch fucking pecl to read php.ini
RUN \
  sed -i "s|$PHP -C -n -q |$PHP -C -q |" /usr/bin/pecl

RUN \
  pecl channel-update pecl.php.net

# hadolint ignore=DL4006
RUN \
  (yes '' | pecl install yaml) && \
  (yes '' | pecl install xdebug)

# ---------------------------------------------------------------------------------------

FROM alpine:3.10 as stage2

ARG VCS_REF
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_TYPE
ARG ICINGAWEB_VERSION
ARG INSTALL_THEMES
ARG INSTALL_MODULES

# hadolint ignore=DL3018
RUN \
  apk update  --quiet --no-cache && \
  apk add     --quiet --no-cache \
    bash \
    ca-certificates \
    curl \
    composer \
    jq \
    git

# hadolint ignore=DL3018
RUN \
  apk add     --quiet --no-cache \
    php7 \
    php7-ctype \
    php7-openssl \
    php7-intl \
    php7-gettext

COPY build /build

WORKDIR /tmp

# hadolint ignore=DL3003,DL4006
RUN \
  mkdir /usr/share/webapps && \
  if [ -z "${BUILD_TYPE}" ] || [ "${BUILD_TYPE}" = "stable" ] ; then \
    echo "install icingaweb2 v${ICINGAWEB_VERSION}" && \
    curl \
      --silent \
      --location \
      --retry 3 \
      --cacert /etc/ssl/certs/ca-certificates.crt \
      "https://github.com/Icinga/icingaweb2/archive/v${ICINGAWEB_VERSION}.tar.gz" \
      | gunzip \
      | tar x -C /usr/share/webapps/ && \
    ln -s "/usr/share/webapps/icingaweb2-${ICINGAWEB_VERSION}" /usr/share/webapps/icingaweb2 ; \
  else \
    echo "install icingaweb2 from git " && \
    git clone https://github.com/Icinga/icingaweb2.git && \
    cd icingaweb2 && \
    version=$(git describe --tags --always | sed 's/^v//') && \
    echo "  version: ${version}" && \
    rm -rf /tmp/icingaweb2/.git* && \
    rm -rf /tmp/icingaweb2/.puppet && \
    mv /tmp/icingaweb2 /usr/share/webapps/ ; \
  fi

RUN \
  ln -s /usr/share/webapps/icingaweb2/bin/icingacli /usr/bin/icingacli && \
  mkdir -p /var/log/icingaweb2 && \
  mkdir -p /etc/icingaweb2/modules && \
  mkdir -p /etc/icingaweb2/enabledModules

#RUN \
#  /build/install_modules.sh

#RUN \
#  /build/install_themes.sh

COPY build/icingaweb2-modules /usr/share/webapps/icingaweb2/modules/
COPY build/icingaweb2-themes  /usr/share/webapps/icingaweb2/modules/

RUN \
  /build/install_themes.sh

# ---------------------------------------------------------------------------------------

FROM alpine:3.10 as final

ARG VCS_REF
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_TYPE
ARG ICINGAWEB_VERSION
ARG INSTALL_THEMES
ARG INSTALL_MODULES

COPY --from=stage1 /usr/lib/php7/modules/yaml.so   /usr/lib/php7/modules/
COPY --from=stage1 /usr/lib/php7/modules/xdebug.so /usr/lib/php7/modules/
COPY --from=stage2 /usr/share/webapps              /usr/share/webapps
COPY --from=stage2 /etc/icingaweb2                 /etc/icingaweb2

# hadolint ignore=DL3017,DL3018
RUN \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add     --quiet --no-cache \
    bash \
    bind-tools \
    ca-certificates \
    curl \
    inotify-tools \
    jq \
    mysql-client \
    nginx \
    netcat-openbsd \
    openssl \
    php7 \
    php7-ctype \
    php7-fpm \
    php7-pdo_mysql \
    php7-openssl \
    php7-intl \
    php7-ldap \
    php7-gettext \
    php7-json \
    php7-mbstring \
    php7-curl \
    php7-iconv \
    php7-session \
    php7-xml \
    php7-dom \
    php7-soap \
    php7-sockets \
    php7-posix \
    php7-pcntl \
    php7-gmp \
    shadow \
    tzdata \
    pwgen \
    yaml \
    yajl-tools && \
  cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
  echo "extension=yaml.so"        > /etc/php7/conf.d/ext-yaml.ini && \
  echo "zend_extension=xdebug.so" > /etc/php7/conf.d/ext-xdebug.ini.disabled && \
  sed -i -e '/^#/ d' -e '/^;/ d'  -e '/^ *$/ d' /etc/php7/php.ini && \
  ln -s /usr/share/webapps/icingaweb2/bin/icingacli /usr/bin/icingacli && \
  mkdir -p /var/log/icingaweb2 && \
  /usr/bin/icingacli module disable setup && \
  /usr/bin/icingacli module enable monitoring  2> /dev/null && \
  /usr/bin/icingacli module enable translation 2> /dev/null && \
  /usr/bin/icingacli module enable doc         2> /dev/null && \
  mkdir /run/nginx && \
  mkdir /var/log/php-fpm && \
  apk del --quiet \
    tzdata && \
  rm -rf \
    /build \
    /tmp/* \
    /var/cache/apk/*

COPY rootfs/ /

WORKDIR /etc/icingaweb2

VOLUME ["/etc/icingaweb2", "/usr/share/webapps/icingaweb2", "/init/custom.d"]

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --retries=12 \
  CMD curl --silent --fail http://localhost/health || exit 1

CMD ["/init/run.sh"]

# ---------------------------------------------------------------------------------------

# Build-time metadata as defined at http://label-schema.org
LABEL \
  version=${BUILD_VERSION} \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="IcingaWeb2 Docker Image" \
  org.label-schema.description="Inofficial IcingaWeb2 Docker Image" \
  org.label-schema.url="https://www.icinga.org/" \
  org.label-schema.vcs-ref=${VCS_REF} \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-icingaweb2" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${ICINGAWEB_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="GNU General Public License v3.0"

# ---------------------------------------------------------------------------------------
