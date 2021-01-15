FROM alpine:latest

MAINTAINER Jim McVea <jmcvea@gmail.com>

LABEL Description="Provides openstack client tools" Version="0.1"

# Alpine-based installation
# #########################
RUN apk add --update \
  python-dev \
  py-pip \
  py-setuptools \
  ca-certificates \
  gcc \
  libffi-dev \
  openssl-dev \
  musl-dev \
  linux-headers \
  && pip install --upgrade --no-cache-dir pip setuptools python-openstackclient \
  && apk del gcc musl-dev linux-headers libffi-dev \
  && rm -rf /var/cache/apk/*

# Add a volume so that a host filesystem can be mounted 
# Ex. `docker run -v $PWD:/data jmcvea/openstack-client`
VOLUME ["/data"]

# Default is to start a shell.  A more common behavior would be to override
# the command when starting.
# Ex. `docker run -ti jmcvea/openstack-client openstack server list`
CMD ["/bin/sh"]

