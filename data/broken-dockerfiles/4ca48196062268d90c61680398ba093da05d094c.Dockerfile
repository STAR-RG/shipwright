FROM node:latest
MAINTAINER Andre Ferreira <andrehrf@gmail.com>

RUN mkdir -p /home/app
ENV HOME=/home/app
COPY package.json $HOME
WORKDIR $HOME
RUN npm install --progress=false --no-optional
COPY . $HOME

CMD ["npm", "start"]