FROM phusion/baseimage:0.9.19

MAINTAINER Ahumaro Mendoza <ahumaro@ahumaro.com>

CMD ["/sbin/my_init"]

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

#Install core packages
RUN apt-get update -q
RUN apt-get upgrade -y -q
RUN apt-get install -y -q php php-cli php-fpm php-gd php-curl php-apcu php-xml php-mbstring php-zip ca-certificates nginx git-core
RUN apt-get clean -q && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Get Grav
RUN rm -fR /usr/share/nginx/html/
RUN git clone https://github.com/getgrav/grav.git /usr/share/nginx/html/

#Install Grav
WORKDIR /usr/share/nginx/html/
RUN bin/composer.phar self-update
RUN bin/grav install
RUN chown -R www-data:www-data *
RUN find . -type f | xargs chmod 664
RUN find . -type d | xargs chmod 775
RUN find . -type d | xargs chmod +s
RUN umask 0002

#Configure Nginx - enable gzip
RUN sed -i 's|# gzip_types|  gzip_types|' /etc/nginx/nginx.conf

#Setup Grav configuration for Nginx
RUN touch /etc/nginx/grav_conf.sh
RUN chmod +x /etc/nginx/grav_conf.sh
RUN echo '#!/bin/bash \n\
    echo "" > /etc/nginx/sites-available/default \n\
    ok="0" \n\
    while IFS="" read line \n\
    do \n\
        if [ "$line" = "server {" ]; then \n\
            ok="1" \n\
        fi \n\
        if [ "$ok" = "1" ]; then \n\
            echo "$line" >> /etc/nginx/sites-available/default \n\
        fi \n\
        if [ "$line" = "}" ]; then \n\
            ok="0" \n\
        fi \n\
    done < /usr/share/nginx/html/webserver-configs/nginx.conf' >> /etc/nginx/grav_conf.sh
RUN /etc/nginx/grav_conf.sh
RUN sed -i \
        -e 's|root /home/USER/www/html|root   /usr/share/nginx/html|' \
        -e 's|unix:/var/run/php5-fpm.sock;|unix:/run/php/php7.0-fpm.sock;|' \
    /etc/nginx/sites-available/default

#Setup Php service
RUN mkdir -p /run/php/
RUN touch /run/php/php7.0-fpm.sock
RUN mkdir -p /etc/service/php-fpm
RUN touch /etc/service/php-fpm/run
RUN chmod +x /etc/service/php-fpm/run
RUN echo '#!/bin/bash \n\
    exec /usr/sbin/php-fpm7.0 -F' >> /etc/service/php-fpm/run

#Setup Nginx service
RUN mkdir -p /etc/service/nginx
RUN touch /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
RUN echo '#!/bin/bash \n\
    exec /usr/sbin/nginx -g "daemon off;"' >>  /etc/service/nginx/run

#Setup SSH service
RUN sed -i \
        -e 's|#PasswordAuthentication no|PasswordAuthentication no|' \
        -e 's|#UsePAM yes|UsePAM no|' \
    /etc/ssh/sshd_config
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

#Expose configuration and content volumes
VOLUME /root/.ssh/ /etc/nginx/ /usr/share/nginx/html/

#Public ports
EXPOSE 80 22
