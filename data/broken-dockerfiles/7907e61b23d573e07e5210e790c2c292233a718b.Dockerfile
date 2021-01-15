FROM node:argon

MAINTAINER xavero

RUN useradd -ms /bin/bash node
ENV HOME /home/node
USER node

WORKDIR /home/node

COPY . /home/node
RUN npm install

CMD [ "npm", "start" ]