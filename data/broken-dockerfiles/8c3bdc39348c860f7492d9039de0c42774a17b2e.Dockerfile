FROM node:current-alpine
WORKDIR /graphql-dashboard

COPY ./package.json /graphql-dashboard

RUN yarn install --pure-lockfile && yarn cache clean

COPY . .

RUN yarn run build

ENV NODE_ENV production
CMD node ./dist/index.js
USER node