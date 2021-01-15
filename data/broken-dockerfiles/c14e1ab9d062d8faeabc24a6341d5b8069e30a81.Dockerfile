# Dockerfile for scraypd
# http://scrapyd.readthedocs.org/en/latest/

FROM stackbrew/ubuntu:14.04
MAINTAINER Zaim Bakar <hi.zaimapps@gmail.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 627220E7
RUN echo 'deb http://archive.scrapy.org/ubuntu scrapy main' > /etc/apt/sources.list.d/scrapy.list

RUN apt-get update -qq && apt-get install -y scrapyd

# Expose scrapyd default port
EXPOSE 6800

VOLUME ["/var/lib/scrapyd"]
VOLUME ["/var/log/scrapyd"]

# Set scrapyd as run entrypoint
CMD ["/usr/bin/scrapyd"]
