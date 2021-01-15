## -*- docker-image-name: "mcreations/ftp" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV FTP_USER ftp
ENV FTP_PASS changeit

# the HOST var is necessary for passive mode, so the client knows
# where to connect, if you are not running the docker container
# locally, you MUST specify a host name which is resolvable over the
# network
ENV HOST localhost
ENV PASV_MIN_PORT 65000
ENV PASV_MAX_PORT 65100

ADD image/root/ /

RUN opkg update &&\
    opkg install --force-checksum vsftpd shadow-useradd shadow-groupadd shadow-usermod openssl-util &&\
    rm /tmp/opkg-lists/*

EXPOSE 21
EXPOSE 65000-65100

CMD ["/start-ftp"]
