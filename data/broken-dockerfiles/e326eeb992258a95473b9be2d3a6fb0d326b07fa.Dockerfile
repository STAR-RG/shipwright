FROM ubuntu:16.10
MAINTAINER BlackCarrot <dev@blackcarrot.be>
LABEL description="DashPayments for WooCommerce Plugin"

RUN /bin/echo 'set -o vi' >> /etc/profile
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install aptitude vim openssl build-essential zip unzip
RUN apt-get -y install php7.0 php7.0-fpm php7.0-gmp php7.0-bcmath php7.0-gd php7.0-mcrypt php7.0-curl php7.0-json composer php-composer-ca-bundle
RUN rm -fr /var/cache/apt/*

COPY . /dp4wc/dashpay-woocommerce/
WORKDIR /dp4wc

# install deps & check syntax
RUN (cd /dp4wc/dashpay-woocommerce/ && composer install)
RUN (cd /dp4wc/dashpay-woocommerce/ && /bin/bash check.sh)

# remove files not required for plugin
RUN cd /dp4wc/dashpay-woocommerce/ && rm -fr .git* Dockerfile composer* README.md check.sh

RUN zip -r dashpay-woocommerce.zip dashpay-woocommerce/
RUN rm -fr /dp4wc/dashpay-woocommerce/

CMD ["/bin/bash", "--rcfile", "/etc/profile"]
