# Set the base image to Ubuntu
FROM ubuntu:trusty

# File Author / Maintainer
MAINTAINER bitponics

################## UPDATE apt-GET ######################
RUN export DEBIAN_FRONTEND=noninteractive
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN sudo apt-get update
RUN sudo apt-get upgrade -y

################## INSTALL SSH AND SUPERVISOR AND CREATE DIRS ######################
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

##################### SUPERVISOR - ADD CONFIG #####################
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

################## MONGO - BEGIN INSTALLATION ######################
# Install MongoDB Following the Instructions at MongoDB Docs
# Ref: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

# Add the package verification key
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

# Add MongoDB to the repository sources list
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

# update packages
RUN sudo apt-get update

# Install MongoDB package (.deb)
RUN sudo apt-get install -y mongodb-10gen

# Create the default data directory
RUN mkdir -p /data/db

# Expose the default port
EXPOSE 27017

# Default port to execute the entrypoint (MongoDB)
#CMD ["--port 27017"]

# Set default container command
# ENTRYPOINT usr/bin/mongod
##################### MONGO - INSTALLATION END #####################

##################### REDIS - INSTALLATION START #####################
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

RUN sudo apt-get install -y redis-server

# update packages
#RUN apt-get update
#
#RUN apt-get install -y build-essential tcl valgrind
#
#ADD . /usr/src/redis
#
#RUN make -C /usr/src/redis
#
## in initial testing, "make test" was failing for reasons that were very hard to track down (so for now, we run them, but don't worry about them #failing)
#RUN make -C /usr/src/redis test || true
#
#RUN make -C /usr/src/redis install
#
USER redis

EXPOSE 6379

# CMD [ "redis-server", "--bind", "0.0.0.0" ]
##################### REDIS - INSTALLATION END #####################

##################### NODE #####################
FROM dockerfile/python

RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bash_profile

RUN sudo apt-get install -y npm

ADD . /usr/src/app
WORKDIR /usr/src/app

# install your application's dependencies
RUN npm install

# replace this with your application's default port
EXPOSE 80

###################### END NODE #####################

##################### RUN COMMANDS VIA SUPERVISOR #####################
CMD ["/usr/bin/supervisord", "-n"]





###
## NodeJS MongoDB Redis
##
## This creates an image which contains an environment for NodeJS app ecosystem
## - Node.js 0.10.23
## - MongoDB 2.4.8
## - Redis 2.4.15
###
#
#FROM truongsinh/nodejs
#
#MAINTAINER TruongSinh Tran-Nguyen <i@truongsinh.pro>
#
## Fix upstart under a virtual host https://github.com/dotcloud/docker/issues/1024
#RUN dpkg-divert --local --rename --add /sbin/initctl \
# && ln -s /bin/true /sbin/initctl
#
## Configure Package Management System (APT) & install MongoDB
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 \
# && echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list \
# && apt-get update \
# && apt-get install -y mongodb-10gen
#
## Redis server
#RUN apt-get install -y redis-server
#
## Start MongoDB
#CMD mongod --fork -f /etc/mongodb.conf \
# && redis-server /etc/redis/redis.conf \
# && bash
