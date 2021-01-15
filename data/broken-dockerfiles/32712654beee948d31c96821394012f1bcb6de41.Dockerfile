FROM debian:jessie

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 \
	&& echo 'deb http://deb.torproject.org/torproject.org jessie main' >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install tor tor-geoipdb \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY torrc /etc/tor/

RUN mv /var/lib/tor / && ln -s /tor /var/lib/

CMD /usr/bin/tor
