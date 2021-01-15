FROM node:6

MAINTAINER CT WiFi

ADD package.json /tmp/package.json
ADD bower.json /tmp/bower.json

RUN \
  cd /tmp && \
  npm install -g bower grunt-cli && \
  npm install --production && \
  bower install --config.interactive=false --allow-root

RUN mkdir -p /opt/app && cp -a /tmp/node_modules /opt/app

WORKDIR /opt/app/dist

ADD . /opt/app

RUN grunt build

CMD ["node", "server/app.js"]
