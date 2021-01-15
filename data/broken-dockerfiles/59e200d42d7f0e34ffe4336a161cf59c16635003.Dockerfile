FROM    centos:centos6
MAINTAINER mlabouardy <mohamed@labouardy.com>

RUN     yum install -y epel-release
RUN     yum install -y nodejs npm

# Install app dependencies
COPY package.json /src/package.json
RUN cd /src; npm install

# Bundle app source
COPY . /src

EXPOSE  3000
CMD ["node", "/src/server.js"]
