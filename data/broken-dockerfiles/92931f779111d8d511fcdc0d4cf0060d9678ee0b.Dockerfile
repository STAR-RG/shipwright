FROM containership/alpine-node-yarn:3.5-6.9.2-0.18.1

MAINTAINER ContainerShip Developers <developers@containership.io>

# create /app and add files
WORKDIR /app
ADD . /app

# set default NODE_ENV=development
ENV NODE_ENV development
ENV CS_NO_ANALYTICS true

# install required packages and dependencies
RUN apk --update add --no-cache --virtual .build-deps build-base python-dev ruby-dev ruby-bundler libffi-dev \
    && apk add --no-cache ca-certificates git iptables ruby-irb \
    && yarn install --pure-lockfile --ignore-engines --production \
    && gem install ohai --no-document \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# create tmp directory for codexd snapshots
RUN mkdir -p /tmp/codexd

# expose ports
EXPOSE 2666
EXPOSE 2777
EXPOSE 80

# specify volumes
VOLUME /var/run/docker.sock
VOLUME /var/log/containership
VOLUME /root/.containership
VOLUME /opt/containership

# set entrypoint
ENTRYPOINT ["node", "index.js"]
