ARG ARCHREPO
FROM ${ARCHREPO}/node:12

ENV NODE_ENV=production
ENV COMPILED=true

ARG QEMU_ARCH
COPY qemu-${QEMU_ARCH}-static /usr/bin/

RUN apt-get update && apt-get install -y ffmpeg libogg-dev

COPY ./bin /opt/cast/
COPY ./package.json /opt/cast/package.json
COPY ./package-lock.json /opt/cast/package-lock.json
COPY ./intern/streams/icy /opt/cast/intern/streams/icy
COPY ./public /opt/cast/public
WORKDIR /opt/cast/

RUN npm install

CMD node server.js
