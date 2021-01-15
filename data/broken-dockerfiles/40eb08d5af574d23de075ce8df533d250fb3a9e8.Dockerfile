############################
# Build container
############################
FROM node:10-alpine AS dep

WORKDIR /ops

RUN apk add python

ADD package.json .
RUN npm install

ADD . .

RUN mkdir lib

RUN npm run build

############################
# Final container
############################
FROM node:10-alpine

WORKDIR /ops

RUN apk --update add git make vim && npm install -g typescript && npm install -g ts-node @types/node

COPY --from=dep /ops .
