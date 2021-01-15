FROM ubuntu

ENV TERM=xterm \
    SHELL=bash \
    DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production \
    PHP_VERSION=7.2 \
    NODE_VERSION=12.x

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
    bash supervisor nginx git curl sudo zip unzip xz-utils libxrender1 gnupg \
    php php-apcu php-bz2 php-cli php-curl php-fpm php-gd php-geoip \
    php-gettext php-gmp php-imagick php-imap php-json php-mbstring php-zip \
    php-memcached php-mongodb php-mysql php-pear php-redis php-xml php-intl php-soap \
    php-sqlite3 php-dompdf php-fpdf php-ssh2 php-bcmath && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | sudo -E bash && \
    apt-get install -y nodejs && \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- && \
    ln -sfv /root/.yarn/bin/yarn /bin && \
    rm -rf /var/cache/apt && rm -rf /var/lib/apt && \
    curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin --filename=composer && \
    mkdir -p /run/php && \
    mkdir -p /var/www && \
    chown -R www-data:www-data /var/www /root

ENV HOME=/var/www
EXPOSE 80
ENTRYPOINT ["entrypoint"]

RUN ln -vs /var/www/ /home/www-data && \
    ln -fs /conf/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    ln -fs /conf/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini && \
    ln -fs /conf/nginx.conf /etc/nginx/nginx.conf && \
    ln -fs /conf/nginx-default /etc/nginx/conf.d/default.conf && \
    ln -fs /conf/supervisord.conf /etc/supervisord.conf

COPY bin /bin
COPY conf /conf

