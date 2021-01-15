FROM resin/rpi-supervisor:6659c1

RUN apt-get -q update && apt-get install -qy libasound2-dev ntpdate

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/app/vendor/node/bin

ADD . /sonos

ADD start /start
