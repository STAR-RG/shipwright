FROM node:8-alpine

WORKDIR /usr/src/app
EXPOSE 3000

# Copies dependencies in seperate layers
COPY package.json yarn.lock /usr/src/app/

RUN NODE_ENV=development

RUN yarn install --frozen-lockfile

ADD . /usr/src/app

CMD yarn dev
