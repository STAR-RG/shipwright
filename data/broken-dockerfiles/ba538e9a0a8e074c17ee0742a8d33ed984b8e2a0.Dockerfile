FROM helder/nginx-extras
MAINTAINER Federico Gonzalez <https://github.com/fedeg>

RUN apt-get update -qq \
 && apt-get install -y curl git build-essential make ruby-all-dev ruby-dev ruby rubygems-integration \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nodejs
ENV NODE_VERSION 0.10.46
RUN curl -sL https://deb.nodesource.com/setup_0.10 | bash -
RUN apt-get install -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm config set registry http://registry.npmjs.org
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g bower grunt-cli && npm cache clean
COPY package.json /usr/src/app/
RUN npm install && npm cache clean
COPY .bowerrc /usr/src/app/
COPY bower.json /usr/src/app/
RUN bower install --allow-root --force-latest
RUN gem install --no-rdoc --no-ri sass -v 3.4.22
RUN gem install --no-rdoc --no-ri compass
COPY docker/nginx/default /etc/nginx/sites-available/default
COPY docker/build.sh /usr/src/app/build.sh
COPY . /usr/src/app
RUN mkdir -p /var/www

VOLUME /var/www
CMD ["/usr/src/app/build.sh"]
