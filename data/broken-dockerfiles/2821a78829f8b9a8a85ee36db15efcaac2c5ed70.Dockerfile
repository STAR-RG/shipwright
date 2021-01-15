# Dockerfile for MySQL proxy + Pantheon Terminus

FROM pataquets/mysql-proxy

# Add our runtime script and the mysql-proxy lua script.
ADD run /opt/run
ADD terminus_auth.lua /opt/auth.lua
RUN chmod u+x /opt/run

# Install PHP, terminus, etc.
RUN apt-get -qq update \
  && apt-get -qqy upgrade \
  && apt-get -qqy install software-properties-common \
  && add-apt-repository ppa:ondrej/php \
  && apt-get -qq update \
  && apt-get -qqy --force-yes upgrade \
  && apt-get -qqy --force-yes install --no-install-recommends \
    curl \
    openssh-client \
    php7.2-cli \
    php7.2-common \
    php7.2-curl \
    php7.2-zip \
    php7.2-dom \
    php7.2-xml \
  && apt-get clean
RUN mkdir -p $HOME/.terminus/plugins \
  && mkdir -p $HOME/terminus \
  && curl -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar && php installer.phar install --install-version=1.9.0 --install-dir=$HOME/terminus \
  && curl https://github.com/terminus-plugin-project/terminus-replica-plugin/archive/1.0.0.tar.gz -L -o $HOME/.terminus/plugins/replica.tar.gz \
  && cd $HOME/.terminus/plugins && tar -zxvf replica.tar.gz

# You should customize these at run-time.
ENV PROXY_DB_UN=pantheon_proxy
ENV PROXY_DB_PW=change-me-pw-for-proxy
ENV PROXY_DB_PORT=3306
ENV PANTHEON_EMAIL=test@example.com
ENV PANTHEON_TOKEN=
ENV PANTHEON_SITE=example
ENV PANTHEON_ENV=test

# Override command/entrypoint from upstream image
ENTRYPOINT ["/opt/run"]
CMD []
