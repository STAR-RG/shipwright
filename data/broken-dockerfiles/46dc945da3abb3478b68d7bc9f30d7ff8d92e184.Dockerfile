FROM node:6
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

RUN mkdir -p /var/www
WORKDIR /var/www

ADD ./package.json /var/www
RUN $HOME/.yarn/bin/yarn install

RUN mkdir -p /var/www/lib /var/www/bot /var/www/models /var/www/public /var/www/certs
ADD ./index.js /var/www
ADD ./config.prod.json /var/www/config.json
ADD ./lib /var/www/lib
ADD ./bot /var/www/bot
ADD ./models /var/www/models
ADD ./public /var/www/public
