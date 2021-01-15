FROM oskarirauta/alpine:latest
MAINTAINER Oskari Rauta <oskari.rauta@gmail.com>

# Environment variables
ENV LOCAL_NETWORK=
ENV OPENVPN_USERNAME=**None**
ENV OPENVPN_PASSWORD=**None**
ENV OPENVPN_PROVIDER=**None**
ENV OPENVPN_CONFIG=**None**
ENV PUID=1001
ENV PGID=2001
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# Volumes
VOLUME /config
VOLUME /data
VOLUME /etc/openvpn

# Exposed ports
EXPOSE 8112 58846 58946 58946/udp

# Install runtime packages
RUN \
 apk add --no-cache \
	ca-certificates \
	p7zip \
	unrar \
	unzip \
	shadow \
	openvpn \
	dcron \
 && apk add --no-cache \
	--repository "http://nl.alpinelinux.org/alpine/edge/main" \
	libressl2.5-libssl \
 && apk add --no-cache \
	--repository "http://nl.alpinelinux.org/alpine/edge/testing" \
	deluge
 
# Install build packages
RUN apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	libffi-dev \
	libressl-dev \
	py2-pip \
	python2-dev

# install pip packages
RUN pip install --no-cache-dir -U \
	incremental \
	pip \
 && pip install --no-cache-dir -U \
	crypto \
	mako \
	markupsafe \
	pyopenssl \
	service_identity \
	six \
	twisted \
	zope.interface

# cleanup
RUN apk del --purge build-dependencies \
 && rm -rf /root/.cache

# Create user and group
RUN addgroup -S -g 2001 media
RUN adduser -SH -u 1001 -G media -s /sbin/nologin -h /config deluge

# add local files and replace init script
RUN rm /etc/init.d/openvpn
COPY openvpn/ /etc/openvpn/
COPY init/ /etc/init.d/
COPY /cron/root /etc/crontabs/root

RUN rc-update add openvpn-serv default
RUN rc-update add dcron default
