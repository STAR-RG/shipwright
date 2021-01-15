FROM ubuntu:latest

MAINTAINER Michael Lawrence <me@mikelawrence.co>

VOLUME ["/starbound"]

COPY start.sh /start.sh

RUN apt-get update \
	&& apt-get install lib32gcc1 wget libpng12-0 -y \
	&& mkdir -p /starbound /steamcmd \
	&& cd /steamcmd \
	&& wget -o /tmp/steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
	&& tar zxvf steamcmd_linux.tar.gz \
	&& rm steamcmd_linux.tar.gz \
	&& chmod +x ./steamcmd.sh /start.sh

EXPOSE 21025
EXPOSE 21026

CMD /start.sh
