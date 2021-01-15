FROM alpine

RUN apk update \
    # only for build miio
    && apk add --no-cache --virtual .build-deps \
    build-base \
    python3-dev \
    && apk add --no-cache \
    apache2 \
    curl \
    git \
    libcap \
    libffi-dev \
    linux-headers \
    openssl-dev \
    php7 \
    php7-apache2 \
    php7-curl \
    php7-mysqli \
    php7-mbstring \
    php7-phar \
    php7-json \
    php7-zip \
    py-bottle \
    py-mysqldb \
    py-pillow \
    py-pip \
    python3 \
    tzdata \
    && pip3 install --upgrade pip \
    && pip3 install python-miio \
    pymysql \
    && apk del .build-deps \
    && rm -f /var/cache/apk/*


###########################################################################
# Copy dustcloud Data
ENV DUSTCLOUD /opt/dustcloud
ENV WWWDATA $DUSTCLOUD/www
ENV GITDIR /gitdata
RUN git clone --depth 1 https://github.com/dgiese/dustcloud.git $GITDIR && \
    cd /gitdata && \
    mkdir -p $DUSTCLOUD && \
    cp -r $GITDIR/dustcloud/www $DUSTCLOUD && \
    cp $GITDIR/devices/xiaomi.vacuum.gen1/mapextractor/extractor.py $DUSTCLOUD/map_extractor.py && \
    cp $GITDIR/dustcloud/server.py $DUSTCLOUD/server.py.master && \
    cp $GITDIR/dustcloud/build_map.py $DUSTCLOUD/build_map.py && \
    cp $GITDIR/dustcloud/config.sample.ini $DUSTCLOUD/config.master.ini && \
    echo 'su -c "python3 $DUSTCLOUD/server.py --enable-live-map" -s /bin/sh - apache' > $DUSTCLOUD/server.sh && \
    chmod +x $DUSTCLOUD/server.sh && \
    echo "<?php phpinfo(); ?>" > $WWWDATA/public/info.php && \
    rm -rf $GITDIR

# Change vars in server.py.master
RUN sed -i -e "s/cmd_server.run(host=\"localhost\", port=cmd_server_port)/cmd_server.run(host=\"0.0.0.0\", port={{CMDSERVER_PORT}})/g" $DUSTCLOUD/server.py.master && \
    sed -i -e "s/cloud_server_address = ('ott.io.mi.com', 80)/cloud_server_address = ('{{CLOUD_SERVER_ADDRESS}}', 80)/g" $DUSTCLOUD/server.py.master

###########################################################################
# Customization config.master.ini
RUN sed -i -e "s/ip = 10.0.0.1/ip = {{CLOUDSERVERIP}}/g" $DUSTCLOUD/config.master.ini && \
    sed -i -e "s/host = 127.0.0.1/host = {{MYSQLSERVER}}/g" $DUSTCLOUD/config.master.ini && \
    sed -i -e "s/database = dustcloud/database = {{MYSQLDB}}/g" $DUSTCLOUD/config.master.ini && \
    sed -i -e "s/username = dustcloud/username = {{MYSQLUSER}}/g" $DUSTCLOUD/config.master.ini && \
    sed -i -e "s/password = dustcloud/password = {{MYSQLPW}}/g" $DUSTCLOUD/config.master.ini && \
    sed -i -e "s@cmd.server = http://localhost:1121/@cmd.server = http://{{CMDSERVER}}:{{CMDSERVER_PORT}}/@g" $DUSTCLOUD/config.master.ini && \
    sed -i -e "s/debug = true/debug = {{DEBUG}}/g" $DUSTCLOUD/config.master.ini

###########################################################################
# Install composer
RUN cd $WWWDATA && \
    curl https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer | php -- && \
    php composer.phar install

###########################################################################
# Customization for PHP and Apache
ENV APACHE_PORT 81

RUN mkdir /run/apache2 && \
    sed -i -e "s/Listen 80/Listen ${APACHE_PORT}/g" /etc/apache2/httpd.conf && \
    sed -i -e "s@/var/www/localhost/htdocs@$WWWDATA/public@g" /etc/apache2/httpd.conf && \
    sed -i -e "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/g" /etc/php7/php.ini && \
    sed -i -e "s/display_errors = Off/display_errors = On/g" /etc/php7/php.ini && \
    sed -i -e "s@;date.timezone =@date.timezone = \"{{TZ}}\"@g" /etc/php7/php.ini && \
    sed -i -e "s/;extension=curl/extension=curl/g" /etc/php7/php.ini

# allow python to bind ports < 1024
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/python3.6



###########################################################################
# Start script
RUN mkdir /bootstrap
ADD start.sh /bootstrap/
RUN chmod +x /bootstrap/start.sh

###########################################################################
# change permission
RUN chgrp -R apache $DUSTCLOUD && \
    chown -R apache $DUSTCLOUD


WORKDIR $DUSTCLOUD

EXPOSE 80/tcp
EXPOSE 81/tcp
EXPOSE 8053/udp
EXPOSE 1121/tcp

CMD ["/bootstrap/start.sh"]

# Build-time metadata as defined at http://label-schema.org
ENV VERSION v1.4.0
ARG BUILD_DATE
ARG VCS_REF
ARG BRANCH
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="dustcloud" \
      org.label-schema.description="Image for Xiaomi Mi Robot Vacuum dustcloud project (https://github.com/dgiese/dustcloud)" \
      org.label-schema.url="https://github.com/JackGruber/docker_dustcloud" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/JackGruber/docker_dustcloud.git" \
      org.label-schema.version="$BRANCH $VERSION" \
      org.label-schema.schema-version="1.0"
