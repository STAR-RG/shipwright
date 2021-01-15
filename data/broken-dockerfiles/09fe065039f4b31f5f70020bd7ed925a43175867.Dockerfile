FROM zzrot/alpine-node:v4.4.2

MAINTAINER ZZROT LLC <docker@zzrot.com>

#ENV VARIABLES
ENV GHOST_SOURCE /usr/src/app
ENV GHOST_CONTENT /var/lib/ghost
ENV GHOST_VERSION 0.11.7
ENV GHOST_URL https://github.com/TryGhost/Ghost/releases/download/${GHOST_VERSION}/Ghost-${GHOST_VERSION}.zip

#Change WORKDIR to ghost directory
WORKDIR $GHOST_SOURCE

RUN apk --no-cache add tar tini \
    && apk --no-cache add --virtual devs gcc make python libarchive-tools curl ca-certificates \
    && curl -sL ${GHOST_URL} | bsdtar -xf- -C ${GHOST_SOURCE} \
	&& npm install --production \
	&& apk del devs \
	&& npm cache clean \
	&& rm -rf /tmp/npm*

#Copy over our configuration filename
COPY ./config.js ${GHOST_SOURCE}

#Copy over, and grant executable permission to the startup script
COPY ./entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE 2368

#Run Init System
ENTRYPOINT ["/sbin/tini"]

#Run Startup script
CMD [ "/entrypoint.sh" ]
