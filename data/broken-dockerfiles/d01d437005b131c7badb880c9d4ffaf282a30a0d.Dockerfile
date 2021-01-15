FROM node:7-alpine

RUN apk --update --no-cache add bash curl jq git \
    && apk add --virtual .builddeps build-base python musl-dev \
    && cd /tmp && npm install keythereum \
    && apk del .builddeps
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /opt/app && cp -a /tmp/node_modules /opt/app/ && rm -rf /tmp/*
WORKDIR /opt/app
ADD lib /opt/app/lib
ADD index.js /opt/app/
ADD scripts /opt/app/scripts
ADD docs /opt/app/docs
EXPOSE 18168
ENTRYPOINT ["node","index.js"]
