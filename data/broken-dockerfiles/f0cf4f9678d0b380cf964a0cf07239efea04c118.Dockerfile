FROM node:9

ADD package.json /app/package.json
WORKDIR /app
RUN yarn install

ADD . /app
RUN yarn build
EXPOSE 3000

CMD ["yarn", "start-server"]
