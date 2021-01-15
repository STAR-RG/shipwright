ARG BASEIMAGE=multiarch/alpine:x86_64-latest-stable
FROM $BASEIMAGE as build-container

ARG CLIENT_TAG=latest
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV
ENV SENTRY_DSN=$SENTRY_DSN

RUN apk add --no-cache --update \
    nodejs \
    nodejs-npm \
    libstdc++ \
    python \
    make \
    gcc \
    g++ && \
    npm install -g --unsafe-perm npm

COPY package*.json "/@ubud-app/server/"
WORKDIR "/@ubud-app/server"
RUN npm ci && \
    cd ../ && \
    npm i "@ubud-app/client@$CLIENT_TAG" --no-save --no-audit --production

COPY . "/@ubud-app/server/"


FROM $BASEIMAGE

ARG UID=1000
ARG GID=1000
ARG CLIENT_TAG=latest
ARG NODE_ENV=production
ARG NEXT
ARG SENTRY_DSN

ENV NODE_ENV=$NODE_ENV
ENV SENTRY_DSN=$SENTRY_DSN
ENV NEXT=$NEXT

RUN apk add --no-cache --update \
    nodejs \
    nodejs-npm && \
    npm install -g --unsafe-perm npm && \
    addgroup -g $GID ubud && \
    adduser -u $UID -G ubud -s /bin/sh -D ubud

COPY --from=build-container "/@ubud-app" "/@ubud-app"

RUN ln -s "/@ubud-app/server/bin/database" "/usr/local/bin/ubud-db" && \
    ln -s "/@ubud-app/server/bin/plugin" "/usr/local/bin/ubud-plugin" && \
    ln -s "/@ubud-app/server/bin/user" "/usr/local/bin/ubud-user" && \
    ln -s "/@ubud-app/server/server.js" "/usr/local/bin/ubud-server" && \
    chown -R ubud:ubud /@ubud-app/server && \
    chown -R ubud:ubud /@ubud-app/server/node_modules && \
    chown -R ubud:ubud /@ubud-app/server/package.json && \
    chown -R ubud:ubud /@ubud-app/server/package-lock.json

USER ubud
WORKDIR "/@ubud-app/server"
CMD ubud-server
