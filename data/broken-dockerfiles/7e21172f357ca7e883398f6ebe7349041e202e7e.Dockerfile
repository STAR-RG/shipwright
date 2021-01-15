FROM mozillamarketplace/centos-phantomjs-mkt:0.1

ENV IS_DOCKER 1

# local redis needed for tests.
RUN yum install -y gcc-c++ redis

RUN mkdir -p /srv/zippy
ADD package.json /srv/zippy/package.json

WORKDIR /srv/zippy

RUN npm cache clean
RUN npm install

EXPOSE 2605
