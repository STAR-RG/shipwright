#FROM resin/%%RESIN_MACHINE_NAME%%-debian
#For RPi1
FROM resin/rpi-raspbian:jessie

#switch on systemd init system in container
ENV INITSYSTEM on

RUN apt-get -q update && apt-get install -yq --no-install-recommends \
	git-core \
	build-essential \
	gcc \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone git://git.drogon.net/wiringPi \
	&& cd wiringPi \
	&& ./build

COPY . /usr/src/app
WORKDIR /usr/src/app

RUN cd packet_forwarder && make

CMD ./packet_forwarder/single_chan_pkt_fwd \
	-u$HOSTS \
	-e$EMAIL_ADDRESS \
	-f$FREQUENCY \
	-lat$LATITUDE \
	-lon$LONGITUDE \
	-alt$ALTITUDE \
	-ss$SS_PIN \
	-dio$DIO_PIN \
	-rst$RST_PIN
