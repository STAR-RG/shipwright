FROM resin/rpi-raspbian:jessie

MAINTAINER Andreas Eiermann <andreas@hypriot.com>

RUN apt-get update && \
apt-get install -y libc6 && \
apt-get clean
# && rm -rf /var/lib/apt/lists/*

COPY content/drone_static /usr/local/bin/drone
COPY content/etc /
#COPY content/lib /lib

ENV DRONE_SERVER_PORT 0.0.0.0:80
ENV DRONE_DATABASE_DATASOURCE /var/lib/drone/drone.sqlite
ENV DRONE_SERVER_PORT :80
#VOLUME ["/var/lib/drone"]

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/drone"]
