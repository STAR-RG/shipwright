FROM node:10-alpine

ENV DIR /src

RUN apk update && apk add \
    make \
    yarn \
    bash

COPY . $DIR
WORKDIR $DIR

RUN yarn
RUN npx lerna bootstrap
RUN yarn storybook:build