FROM node:8.9-alpine

ENV NODE_ENV=production

ENV HOST 0.0.0.0

ADD . /app

WORKDIR /app

RUN npm install --registry=https://registry.npm.taobao.org --unsafe-perm \
      && cp 

EXPOSE 8001 3002

CMD npm deploy