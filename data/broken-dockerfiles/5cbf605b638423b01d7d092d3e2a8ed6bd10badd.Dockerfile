FROM centos:6
MAINTAINER jamlee <jamlee@jamlee.cn>

ENV code_root /code
ENV httpd_conf ${code_root}/config/apache/httpd.conf

#change the software repo

RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
    && rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
    && sed -i -e "s|plugins=1|plugins=0 |" /etc/yum.conf 
ADD ./config/sys/*.repo    /etc/yum.repos.d/ 

RUN yum install -y httpd
RUN yum install --enablerepo=epel,remi-php56,remi -y \
                              php \
                              php-cli \
                              php-gd \
                              php-mbstring \
                              php-mcrypt \
                              php-mysqlnd \
                              php-pdo \
                              php-xml \
                              php-xdebug \
                              tcpdump
RUN yum install -y vim git
RUN sed -i -e "s|^;date.timezone =.*$|date.timezone = PRC |" /etc/php.ini \
    && mv /usr/sbin/tcpdump /usr/local/bin
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && curl -O https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit
ADD ./config/php/config.json /root/.composer/
RUN composer global require "laravel/installer=~1.1"
ENV PATH=$PATH:/root/.composer/vendor/bin
ADD .  $code_root
RUN test -e $httpd_conf && echo "Include $httpd_conf" >> /etc/httpd/conf/httpd.conf
EXPOSE 80
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]

