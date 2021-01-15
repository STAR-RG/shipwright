FROM ubuntu:14.04
MAINTAINER Marcelo Fleury "marcelomf@gmail.com"

ENV LANG C.UTF-8
ENV SERVICE_NAME graojs
ENV SERVICE_VERSION 1

RUN echo "alias ls='ls --color'" >> /etc/profile
RUN apt-get update
RUN ln -s -f /bin/true /usr/bin/chfn
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -yq \
    wget \
    curl \
    git \
    git-core \
    vim \
    python-software-properties \
    software-properties-common \
    g++ \
    build-essential \
    make

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list

#RUN add-apt-repository -y ppa:chris-lea/node.js
RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -yq \
    nodejs \
    node-gyp \
#    npm \
    mongodb-org

RUN mkdir -p /opt/$SERVICE_NAME
ADD . /opt/$SERVICE_NAME
WORKDIR /opt

RUN npm update
#RUN npm install -g node-pre-gyp
#RUN npm install -g node-gyp 
#RUN node-gyp configure || echo "error bypass"
RUN npm install -g bson-ext
RUN npm install -g bson 
RUN npm install -g mongodb
RUN npm install -g graojs
#RUN cd /usr/lib/node_modules/graojs/node_modules/mongodb/node_modules/mongodb-core/ && npm install || echo "error bypass"
RUN cd /usr/lib/node_modules/graojs/node_modules/mongodb/node_modules/mongodb-core/ && npm install bson || echo "error bypass"

RUN service mongodb start && sleep 3 && grao generate:app demo --name demo --description demo --author-name Synack --author-email int@synack.com.br --server-ports 8015,8016 --template-engine jade --theme graojs --mongodb-host localhost --mongodb-db grao

WORKDIR demo

RUN service mongodb start && sleep 3 && grao main:create:admin --username marcelo --name Marcelo --email marcelomf@gmail.com --password admin123

RUN groupadd -r $SERVICE_NAME
RUN useradd -r -s /bin/sh -d /opt/$SERVICE_NAME -c 'service user' -g $SERVICE_NAME $SERVICE_NAME

EXPOSE 8015
EXPOSE 8016
ENTRYPOINT dockerized.sh
