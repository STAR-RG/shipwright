# uwdata/vegaserver
#
# VERSION           0.0.1

FROM phusion/passenger-full

MAINTAINER Timothy Van Heest <timothy.vanheest@gmail.com>

WORKDIR /var/vegaserver

COPY *.js /var/vegaserver/
COPY *.json /var/vegaserver/

RUN /usr/bin/npm install
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["npm", "run", "start"]

EXPOSE 8888
