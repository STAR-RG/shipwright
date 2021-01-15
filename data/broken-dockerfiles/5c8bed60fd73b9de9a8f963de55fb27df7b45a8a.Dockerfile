FROM debian:stable
MAINTAINER Daniele Giglio <giglio.d@gmail.com>

RUN apt-get update 
RUN apt-get install -y apt-utils
RUN apt-get install -y curl ntpdate lsb-release locales
RUN apt-get upgrade -y
RUN locale-gen it_IT it_IT.UTF-8
RUN curl http://deb.kamailio.org/kamailiodebkey.gpg | apt-key add -
#COPY kamailio.list /etc/apt/sources.list.d/
RUN echo "deb     http://deb.kamailio.org/kamailio42 wheezy  main" > /etc/apt/sources.list.d/kamailio.list
RUN echo "deb-src http://deb.kamailio.org/kamailio42 wheezy  main" >> /etc/apt/sources.list.d/kamailio.list
RUN apt-get update
RUN apt-get install -y rsyslog
RUN apt-get install -y procps
RUN apt-get install -y supervisor
RUN apt-get -y install mysql-client
RUN apt-get -y install kamailio kamailio-extra-modules kamailio-ims-modules kamailio-mysql-modules kamailio-nth kamailio-presence-modules kamailio-tls-modules kamailio-websocket-modules kamailio-xml-modules kamailio-xmpp-modules
RUN apt-get -y install net-tools
RUN apt-get clean

# Copies configurations
COPY environment	/etc/
COPY vimrc		/etc/vim/
COPY supervisord.conf 	/etc/supervisor/conf.d/supervisord.conf
COPY kamailio.cfg	/etc/kamailio/
COPY kamctlrc		/etc/kamailio/
COPY tls.cfg		/etc/kamailio/
COPY kamailio		/etc/default/
COPY kamdbctl.mysql 	/usr/lib/x86_64-linux-gnu/kamailio/kamctl/

# RTPproxy stuff
COPY install-rtpproxy.sh	/usr/local/bin/
RUN  chmod +x /usr/local/bin/install-rtpproxy.sh
RUN  /usr/local/bin/install-rtpproxy.sh
COPY rtpproxy		/etc/init.d/
RUN  chmod 755 /etc/init.d/rtpproxy
COPY rtpproxy.conf	/etc/default/rtpproxy

COPY init.sh		/usr/local/bin/
RUN  chmod +x /usr/local/bin/init.sh

EXPOSE 5060 8060 4443 9000 10000-10010

#CMD ["/usr/local/bin/init.sh"]
CMD ["/usr/bin/supervisord"]
