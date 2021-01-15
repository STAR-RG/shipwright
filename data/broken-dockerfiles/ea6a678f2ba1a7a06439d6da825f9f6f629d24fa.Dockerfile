FROM node:latest
ADD . /home/context
WORKDIR /home/context
RUN npm install
RUN npm rebuild node-sass

ENTRYPOINT npm run develop