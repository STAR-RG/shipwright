FROM ubuntu:15.10
COPY setup.sh /
RUN apt-get update && \
    apt-get install python python-pip php5 php5-cli php5-curl php5-sqlite \
    libapache2-mod-php5 apache2 composer -y
RUN pip install supervisor
RUN service apache2 start
RUN mkdir /trunon
WORKDIR /trunon
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/bin/composer
CMD /bin/bash