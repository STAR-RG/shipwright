FROM ubuntu:16.04
LABEL maintainer="harupur"

RUN apt-get update \
 && apt-get -y install apt-utils \
               imagemagick libmagickwand-dev software-properties-common python-software-properties \
               nginx=1.10.3-0ubuntu0.16.04.2 php-fpm \
 && apt-add-repository -y ppa:brightbox/ruby-ng \
 && apt-get update \
 && apt-get -y install ruby2.4 ruby2.4-dev rbenv ruby-build ruby-dev \
 && apt-get -y install language-pack-en \
 && gem install bundler \
 && mkdir -p /var/www/app/sns 

COPY files/sns /var/www/app/sns
RUN  cd /var/www/app/sns/; bundle install

COPY files/conf/nginx-default /etc/nginx/sites-enabled/default
COPY files/conf/nginx.conf /etc/nginx/nginx.conf
COPY files/init.sh /root/init.sh
COPY files/bad_sns_production.sql /root/bad_sns_production.sql
COPY files/rc.local /etc/rc.local

RUN chown -R www-data.www-data /var/www/app \
 && chmod -R 775 /var/www/app/ \
 && chmod 755 /root/init.sh \
 && chmod 755 /etc/rc.local \
 && systemctl enable nginx

EXPOSE 80
CMD ["/sbin/init"]
