FROM ruby:2.3-slim

ENV DRADIS_VERSION="3.0.0.rc1" \
    RAILS_ENV=production \
    APT_ARGS="-y --no-install-recommends --no-upgrade -o Dpkg::Options::=--force-confnew"

# Copy ENTRYPOINT script
ADD docker-entrypoint.sh /entrypoint.sh

RUN apt-get update && \
# Install requirements
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      gcc \
      git \
      libsqlite3-dev \
      make \
      nodejs \
      patch \
      wget && \
# Install Dradis
    wget -q \
      -O /opt/dradisframework-$DRADIS_VERSION.tar.gz \
      https://github.com/dradis/dradisframework/archive/v$DRADIS_VERSION.tar.gz && \
    cd /opt && \
    tar xzf dradisframework-$DRADIS_VERSION.tar.gz && \
    ln -s dradisframework-$DRADIS_VERSION dradis && \
    cd dradis && \
    sed -i 's/^# *\(.*execjs\)/\1/' Gemfile && \
    ruby bin/setup && \
    bundle exec rake assets:precompile && \
    sed -i 's@database:\s*db@database: /dbdata@' /opt/dradis/config/database.yml &&\
# Entrypoint:
    chmod +x /entrypoint.sh && \
# Create dradis user:
    groupadd -r dradis && \
    useradd -r -g dradis -d /opt/dradis dradis && \
    mkdir -p /dbdata && \
    chown -R dradis:dradis /opt/dradis/ /dbdata/ && \
# Clean up:
    apt-get remove -y --purge \
      gcc \
      git \
      libsqlite3-dev \
      make \
      patch \
      wget && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      libsqlite3-0 && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* && \
    rm -f /dbdata/production.sqlite3

WORKDIR /opt/dradis

VOLUME /dbdata

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
