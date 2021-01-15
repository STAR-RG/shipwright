FROM mhart/alpine-node:latest

LABEL description "Run Google Chrome's Lighthouse Audit in the background"

LABEL version="1.0.8"

LABEL author="Matthias Winkelmann <m@matthi.coffee>"
LABEL coffee.matthi.vcs-url="https://github.com/MatthiasWinkelmann/lighthouse-chromium-alpine-docker"
LABEL coffee.matthi.uri="https://matthi.coffee"
LABEL coffee.matthi.usage="/README.md"

WORKDIR /

USER root

RUN echo "http://dl-2.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories
RUN echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "http://dl-2.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

#-----------------
# Set ENV and change mode
#-----------------
ENV LIGHTHOUSE_CHROMIUM_PATH /usr/bin/chromium-browser

ENV TZ "Europe/Berlin"
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV SCREEN_WIDTH 750
ENV SCREEN_HEIGHT 1334
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0
ENV PATH /lighthouse/node_modules/.bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV GEOMETRY "$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

RUN echo $TZ > /etc/timezone

#-----------------
# Add packages
#-----------------

RUN apk -U --no-cache update
RUN apk -U --no-cache add \
    zlib-dev \
    chromium \
    xvfb \
    wait4ports \
    xorg-server \
    dbus \
    ttf-freefont \
    mesa-dri-swrast

RUN npm --global install yarn && yarn global add lighthouse

# Minimize size

RUN apk del --purge --force curl make gcc g++ python linux-headers binutils-gold gnupg git zlib-dev apk-tools libc-utils

RUN rm -rf /var/lib/apt/lists/* \
    /var/cache/apk/* \
    /usr/share/man \
    /tmp/* \
    /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc \
    /usr/lib/node_modules/npm/html \
    /usr/lib/node_modules/npm/scripts

ADD lighthouse-chromium-xvfb.sh /lighthouse/lighthouse-chromium-xvfb.sh

VOLUME /lighthouse/output

ENTRYPOINT ["/lighthouse/lighthouse-chromium-xvfb.sh"]

CMD ["test"]
