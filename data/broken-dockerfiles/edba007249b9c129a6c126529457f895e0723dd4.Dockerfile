FROM node:10-alpine
MAINTAINER Alex Kern <alex@kern.io>

RUN mkdir /app
WORKDIR /app

COPY package.json .
COPY yarn.lock .
RUN NODE_ENV=development yarn install --prefer-offline

COPY tsconfig.json .
COPY src src
ENV NODE_ENV=production
RUN yarn tsc && yarn build-ts && yarn install --prefer-offline

CMD node dist/index.js
