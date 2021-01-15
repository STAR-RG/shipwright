FROM xataz/alpine:3.7

ARG BUILD_CORES
ARG RTORRENT_VER=v0.9.7
ARG LIBTORRENT_VER=v0.13.7

ENV UID=991 \
    GID=991 \
    FLOOD_SECRET=supersecret \
    WEBROOT=/ \
    RTORRENT_SCGI=0 \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

LABEL Description="flood based on alpine" \
      tags="" \
      commit="" \
      maintainer="xataz <https://github.com/xataz>" \
      build_ver="201807010800"

RUN export BUILD_DEPS="build-base \
                        libtool \
                        automake \
                        autoconf \
                        wget \
                        libressl-dev \
                        ncurses-dev \
                        curl-dev \
                        zlib-dev \
                        binutils" \
    && apk add -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main -U ${BUILD_DEPS} \
                ffmpeg \
                ca-certificates \
                gzip \
                zip \
                unrar \
                curl \
                c-ares \
                tini \
                supervisor \
                geoip \
                su-exec \
                libressl \
                file \
                findutils \
                tar \
                xz \
                screen \
                findutils \
                bzip2 \
                bash \
                git \
                cppunit-dev==1.13.2-r1 \
                cppunit==1.13.2-r1 \
                nodejs \
                nodejs-npm \
                python \
                mediainfo \
    ## Download Sources
    && git clone https://github.com/esmil/mktorrent /tmp/mktorrent \
    && git clone https://github.com/mirror/xmlrpc-c.git /tmp/xmlrpc-c \
    && git clone -b ${LIBTORRENT_VER} https://github.com/rakshasa/libtorrent.git /tmp/libtorrent \
    && git clone -b ${RTORRENT_VER} https://github.com/rakshasa/rtorrent.git /tmp/rtorrent \
    && git clone https://github.com/jfurrow/flood/ /app/flood \
    ## Compile mktorrent
    && cd /tmp/mktorrent \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Compile xmlrpc-c
    && cd /tmp/xmlrpc-c/stable \
    && ./configure \
    && make -j ${NB_CORES} \
    && make install \
    ## Compile libtorrent
    && cd /tmp/libtorrent \
    && ./autogen.sh \
    && ./configure \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Compile rtorrent
    && cd /tmp/rtorrent \
    && ./autogen.sh \
    && ./configure --with-xmlrpc-c \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Install flood
    && cd /app/flood \
    && echo "151.101.32.162 registry.npmjs.org" >> /etc/hosts \ 
    && npm install \
    && npm cache clean --force \
    ## Cleanup
    && strip -s /usr/local/bin/rtorrent \
    && strip -s /usr/local/bin/mktorrent \
    && apk del -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main ${BUILD_DEPS} cppunit-dev \
    && rm -rf /var/cache/apk/* /tmp/*

ARG WITH_FILEBOT=NO
ARG FILEBOT_VER=4.7.9
ARG CHROMAPRINT_VER=1.4.3

ENV FILEBOT_RENAME_METHOD="symlink" \
    FILEBOT_RENAME_MOVIES="{n} ({y})" \
    FILEBOT_RENAME_SERIES="{n}/Season {s.pad(2)}/{s00e00} - {t}" \
    FILEBOT_RENAME_ANIMES="{n}/{e.pad(3)} - {t}" \
    FILEBOT_RENAME_MUSICS="{n}/{fn}"

RUN if [ "${WITH_FILEBOT}" == "YES" ]; then \
        apk add -U openjdk8-jre java-jna-native binutils wget \
        && mkdir /filebot \
        && cd /filebot \
        && wget http://downloads.sourceforge.net/project/filebot/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz -O /filebot/filebot.tar.xz \
        && tar xJf filebot.tar.xz \
        && ln -sf /usr/lib/libzen.so.0.0.0 /filebot/lib/x86_64/libzen.so \
        && ln -sf /usr/lib/libmediainfo.so.0.0.0 /filebot/lib/x86_64/libmediainfo.so \
        && wget https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VER}/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz \
        && tar xvf chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz \
        && mv chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64/fpcalc /usr/local/bin \
        && strip -s /usr/local/bin/fpcalc \
        && apk del binutils wget \
        && rm -rf /var/cache/apk/* /tmp/* /filebot/FileBot_${FILEBOT_VER}-portable.tar.xz /filebot/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz /filebot/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64 \
    ;fi

COPY rootfs /
VOLUME /data /config
EXPOSE 3000
RUN chmod +x /usr/local/bin/startup \
    && cd /app/flood \
    && npm run build

ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
