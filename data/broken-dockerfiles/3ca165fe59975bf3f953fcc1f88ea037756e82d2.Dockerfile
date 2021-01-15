FROM ubuntu:quantal
MAINTAINER Lucas Carlson <lucas@rufy.com>

# Let's get haproxy
RUN apt-get update -q
RUN apt-get install -y haproxy

RUN apt-get install -qy supervisor

ADD enabled /etc/default/haproxy
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

ADD /start-haproxy.sh /start-haproxy.sh
ADD /run.sh /run.sh
ADD /supervisord-haproxy.conf /etc/supervisor/conf.d/supervisord-haproxy.conf
RUN chmod 755 /*.sh

EXPOSE 80
CMD ["/run.sh"]
