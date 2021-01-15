FROM      ubuntu:16.04
MAINTAINER Jeffery Utter "jeff@jeffutter.com"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen $LANG \
    && echo "LANG=\"${LANG}\"" > /etc/default/locale \
    && dpkg-reconfigure locales

RUN apt-get -qq update \
    && apt-get install -qq -y curl \
    && curl http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add - \
    && echo deb http://dl.hhvm.com/ubuntu xenial main | tee /etc/apt/sources.list.d/hhvm.list \
    && apt-get -qq update \
    && apt-get install -qq -y hhvm-fastcgi nginx supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/nginx /var/run/hhvm /var/log/supervisor

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#   && ln -sf /dev/stderr /var/log/nginx/error.log \
#   && ln -sf /dev/stderr /var/log/hhvm/error.log

RUN adduser --disabled-login --gecos 'Wordpress' wordpress

RUN cd /home/wordpress \
    && curl -sL http://wordpress.org/latest.tar.gz | tar -xvz

EXPOSE 80

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD setup.sh /setup.sh
RUN chmod 755 /setup.sh
ADD wordpress/wp-config.php /home/wordpress/
ADD wordpress/production-config.php /home/wordpress/
RUN chown wordpress:wordpress /home/wordpress/*.php
ADD server.ini /etc/hhvm/server.ini

CMD ["/usr/bin/supervisord"]
