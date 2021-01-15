# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM tutum/ubuntu:trusty
MAINTAINER Agung Firdaus <agung@jagad.co.id>

# ------------------------------------------------------------------------------
# Install dependencies
RUN apt-get update && apt-get -y install git curl build-essential supervisor

# ------------------------------------------------------------------------------
# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get -y install nodejs

# ------------------------------------------------------------------------------
# Get cloud9 source and install
RUN git clone https://github.com/c9/core.git /tmp/c9
RUN cd /tmp/c9 && scripts/install-sdk.sh
RUN mv /tmp/c9 /cloud9
WORKDIR /cloud9

# ------------------------------------------------------------------------------
# Add workspace volumes
RUN mkdir /cloud9/workspace
VOLUME /cloud9/workspace

# ------------------------------------------------------------------------------
# Set default workspace dir
ENV C9_WORKSPACE /cloud9/workspace

# ------------------------------------------------------------------------------
# Add supervisord conf
ADD supervisord.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8181

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
ENTRYPOINT /usr/bin/supervisord
