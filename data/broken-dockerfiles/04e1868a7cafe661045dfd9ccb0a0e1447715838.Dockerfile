FROM ubuntu
MAINTAINER Adam Butler

RUN apt-get update
RUN apt-get install -y python-software-properties python
RUN add-apt-repository ppa:chris-lea/node.js
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nodejs

RUN npm install -g coffee-script

ADD . /src

RUN cd /src; npm install

EXPOSE  1337

CMD ["coffee", "/src/app.coffee"]

