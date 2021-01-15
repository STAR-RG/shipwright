FROM lsiobase/ubuntu.armhf:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklballs"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
 echo "**** install gnupg and apt-transport-https packages ****" && \
 apt-get update && \
 apt-get install -y \
	apt-transport-https \
	gnupg && \
 echo "**** add dev2day repository ****" && \
 curl -o - https://dev2day.de/pms/dev2day-pms.gpg.key | apt-key add - && \
 echo "deb https://dev2day.de/pms/ stretch main" >> /etc/apt/sources.list.d/plex.list && \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	avahi-daemon \
	dbus \
	plexmediaserver-installer \
	udev \
	unrar \
	wget && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp
VOLUME /config /transcode
