# vim:set ft=dockerfile:
#FROM ubuntu:14.04docker pull
FROM ioft/i386-ubuntu
ENV DEBIAN_FRONTEND=noninteractive
#FROM daald/ubuntu32:Trusty
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties supervisor
RUN add-apt-repository multiverse
# add Precise sources so that Apache 2.2 can be used
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main restricted universe" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise-updates main restricted universe" >> /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y unixodbc libgsf-1-114 imagemagick libglib2.0-dev libt1-5 t1utils ttf-mscorefonts-installer psmisc
RUN apt-get install -y apache2=2.2.22-1ubuntu1 apache2.2-common=2.2.22-1ubuntu1 apache2.2-bin=2.2.22-1ubuntu1 apache2-mpm-worker=2.2.22-1ubuntu1

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* \
	&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove curl

RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG ru_RU.utf8

ENV SERVER_1C_VERSION 8.3.9-2170
ENV SERVER_1C_ARCH i386
ENV DIST_SERVER_1C ./dist/

ADD ${DIST_SERVER_1C} /opt/

RUN if [ ! -f /opt/1c-enterprise83-common_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb ]; then \
    echo File 1c-enterprise83-common_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb does not exist.; \
    echo "DIST_SERVER_1C set incorrectly. See README.md file."; \
    exit 1; fi

RUN if [ ! -f /opt/1c-enterprise83-server_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb ]; then \
    echo File 1c-enterprise83-server_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb does not exist.; \
    echo "DIST_SERVER_1C set incorrectly. See README.md file."; \
    exit 1; fi

RUN dpkg -i /opt/1c-enterprise83-common_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb \
						/opt/1c-enterprise83-server_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb \
						/opt/1c-enterprise83-server-nls_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb \
						/opt/1c-enterprise83-common-nls_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb \
						/opt/1c-enterprise83-crs_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb \
						/opt/1c-enterprise83-ws_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb \
						/opt/1c-enterprise83-ws-nls_${SERVER_1C_VERSION}_${SERVER_1C_ARCH}.deb
RUN rm -f /opt/*.deb

RUN mkdir -p /opt/1C/v8.3/${SERVER_1C_ARCH}/conf/
COPY logcfg.xml /opt/1C/v8.3/${SERVER_1C_ARCH}/conf/
#RUN chown -R usr1cv8:grp1cv8 /opt/1C

RUN mkdir -p /var/log/1c/dumps/
#RUN chown -R usr1cv8:grp1cv8 /var/log/1c/
RUN chmod 755 /var/log/1c

VOLUME /root/.1cv8
VOLUME /var/log/1c
VOLUME /etc/apache2/
VOLUME /var/www/html

COPY docker-entrypoint.sh /
COPY ./1c8_uni2patch_lin /opt/1C/v8.3/i386/
COPY supervisord.conf /etc/supervisor/supervisord.conf

#WORKDIR /opt/1C/v8.3/${SERVER_1C_ARCH}/
#RUN /opt/1C/v8.3/${SERVER_1C_ARCH}/webinst -apache22 -wsdir base -dir '/var/www/html/docs/' -connStr 'Srvr="192.168.99.100";Ref="docs"' -confPath /etc/apache2/apache2.conf
ADD add-web.sh /bin/
RUN chmod +x /bin/add-web.sh
RUN /opt/1C/v8.3/i386/1c8_uni2patch_lin /opt/1C/v8.3/i386/backend.so
RUN /opt/1C/v8.3/i386/1c8_uni2patch_lin /opt/1C/v8.3/i386/backbas.so
COPY www/* /var/www/
COPY default.conf /etc/apache2/sites-available/default
RUN a2enmod rewrite


#CMD ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

EXPOSE 1540-1541 1560-1591 80
