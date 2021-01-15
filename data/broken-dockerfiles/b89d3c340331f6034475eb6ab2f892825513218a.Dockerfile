FROM ubuntu:trusty

MAINTAINER Daniel Mahlow "dmahlow@gmail.com"

RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main universe multiverse' > /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y install apache2 php5 php5-curl php5-mcrypt php5-gd php5-mysql

RUN a2enmod rewrite

ADD apache_default_vhost /etc/apache2/sites-available/default

ADD http://www.magentocommerce.com/downloads/assets/1.8.1.0/magento-1.8.1.0.tar.gz /root/
ADD http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz /root/

RUN tar xzf /root/magento-1.8.1.0.tar.gz -C /root/
RUN tar xzf /root/magento-sample-data-1.6.1.0.tar.gz -C /root/
RUN rm /root/magento-*.gz

RUN rm -fr /var/www
RUN mv /root/magento /var/www
RUN mv /root/magento-sample-data-1.6.1.0/media/* /var/www/media/

RUN chown www-data:www-data -R /var/www

EXPOSE 80

CMD ["bash", "-c", "/usr/sbin/service apache2 start && tail -f /var/log/apache2/access.log"]
