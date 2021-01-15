# Latest Ubuntu LTS
FROM    ubuntu:12.04

#or use a pre-built image
#FROM gusnips/lamp

MAINTAINER Gustavo Salomé <gustavonips@gmail.com>

# Expose apache and mysql
EXPOSE  80
EXPOSE  3306

# Share the volume at correct location
VOLUME /var/www

# Manually add bootstrap files
ADD ./bootstrap.sh /var/www/
ADD ./bootstrap-advanced.sh /var/www/
ADD ./bootstrap-basic.sh /var/www/
ADD ./remove-site.sh /var/www/

# Basic setup
RUN apt-get install -y sudo apt-utils wget

# Set terminal to non-interactive mode
# https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#Setup the server
RUN /bin/bash /var/www/bootstrap.sh vagrant 127.0.0.1 localhost
