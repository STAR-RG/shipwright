## Dockerfile for Alibi
## Inspired by Dockerfile for docker-gitlab by sameersbn

FROM openjdk:8
MAINTAINER freek.paans@infi.nl

ENV ALIBI_VERSION=1.0.0 \
    LEIN_VERSION=2.7.1 \
    ALIBI_INSTALL_DIR="/opt/alibi/alibi" \
    ALIBI_DATA_DIR="/opt/alibi/data"

WORKDIR ${ALIBI_INSTALL_DIR}
RUN cd ${ALIBI_INSTALL_DIR}

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt update && apt install -y curl nodejs

## Install leiningen

# Allow installation as root
ENV LEIN_ROOT=true

# Install leiningen and move to /usr/bin
RUN wget -q -O /usr/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/${LEIN_VERSION}/bin/lein
RUN chmod u=rxw,g=rx,o=rx /usr/bin/lein 

## Copy required assets 
COPY project.clj ${ALIBI_INSTALL_DIR}/project.clj
COPY src ${ALIBI_INSTALL_DIR}/src
COPY resources ${ALIBI_INSTALL_DIR}/resources
COPY config ${ALIBI_INSTALL_DIR}/config
COPY dev ${ALIBI_INSTALL_DIR}/dev
COPY bin ${ALIBI_INSTALL_DIR}/bin
COPY package.json ${ALIBI_INSTALL_DIR}/package.json
COPY Gruntfile.js ${ALIBI_INSTALL_DIR}/

## Install client dependencies
RUN npm install && ./node_modules/.bin/grunt copy

## Build assets
RUN lein cljsbuild once

## Create entrypoint through which commands can be executed
COPY docker/entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

EXPOSE 3000/tcp

VOLUME ["${ALIBI_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["app:start"]
