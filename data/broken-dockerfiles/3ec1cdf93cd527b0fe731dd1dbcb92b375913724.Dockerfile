FROM node:11.4


WORKDIR /home/node/app
ADD ./package.json .
ADD ./yarn.lock .
RUN yarn