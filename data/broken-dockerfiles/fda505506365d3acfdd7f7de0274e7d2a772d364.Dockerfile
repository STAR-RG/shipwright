from stephank/archlinux:armv6-base

EXPOSE 80
EXPOSE 443
EXPOSE 8765

# install setup scripts to prepare system
RUN mkdir -p /tmp/init
WORKDIR /tmp/init
COPY init/hardware.sh .
RUN ./hardware.sh
COPY init/software.sh .
RUN ./software.sh
COPY init/network.sh .
RUN ./network.sh
COPY init/service.sh .
RUN ./service.sh

# install app
ARG CACHEBUST=1
COPY lantern /lantern/
WORKDIR /lantern/
ENTRYPOINT "/lantern/bin/entrypoint"