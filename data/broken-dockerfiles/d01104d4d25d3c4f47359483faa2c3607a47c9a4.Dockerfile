FROM node:6.10
LABEL maintainer "nodejs@netguru.co"

ENV NODE_ENV staging

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

RUN yarn global add swagger sequelize-cli pm2
RUN yarn
RUN sequelize db:migrate

EXPOSE 10010

CMD ["yarn", "start:prod-docker"]
