FROM node:alpine AS builder

WORKDIR /src

RUN apk add --no-cache git  \
                       build-base \
                       python
RUN git clone https://github.com/calxibe/StorjMonitor.git

WORKDIR /src/StorjMonitor

RUN rm -rf node_modules
RUN npm install
RUN chmod +x storjMonitor.sh

FROM node:alpine

ENV TOKEN 1234
ENV STORJ_DAEMON storj
ENV STORJ_PORT 45015

RUN apk add --no-cache python
WORKDIR /src
COPY --from=builder /src/StorjMonitor .

ENTRYPOINT sed -i "s/YOUR-TOKEN-HERE/${TOKEN}/" storjMonitor.js && \
           sed -i "s/127\.0\.0\.1/${STORJ_DAEMON}/" storjMonitor.js && \
           sed -i "s/45015/${STORJ_PORT}/" storjMonitor.js && \
           ./storjMonitor.sh
