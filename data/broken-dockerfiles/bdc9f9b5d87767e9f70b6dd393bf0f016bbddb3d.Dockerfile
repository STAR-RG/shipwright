FROM ubuntu:16.04

ENV NODE_VERSION 7.8.0
ADD https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz /node.tar.gz
RUN tar -xzf /node.tar.gz -C /usr/local --strip-components=1 && rm /node.tar.gz

ADD https://yarnpkg.com/latest.tar.gz /yarn.tar.gz
RUN mkdir -p /yarn && tar -xzf /yarn.tar.gz -C /yarn --strip-components=1 && rm /yarn.tar.gz

RUN mkdir /memorybot
WORKDIR /memorybot

COPY package.json ./
RUN /yarn/bin/yarn install --pure-lockfile

COPY lib/ ./lib/
COPY server.js  ./

ENV DATA_DIR /data
VOLUME /data

CMD ["npm", "run", "-s", "start"]
