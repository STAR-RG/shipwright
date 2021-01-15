# VERSION 0.1
# DOCKER-VERSION  1.4.1
# AUTHOR: spiffyjr <theman@spiffyjr.me>
# DESCRIPTION: Dockerized packmule.io
# TO_BUILD: docker build -t packmule .
# TO_RUN:   docker run -p 8888:80 packmule

# Latest Ubuntu LTS
FROM ubuntu:14.04

# Update
RUN apt-get update \
# Install packmule dependencies
  && apt-get install -y \
    curl \
    git \
    nodejs \
    npm \
    php5 \
# Install composer
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
# Install Bower
  && npm install bower -g \
  && ln -s /usr/bin/nodejs /usr/bin/node \
# Cleanup
  && rm -rf /var/lib/apt/lists/* 

# Copy packmule into container
COPY . /packmule.io
# Change working directory for install
WORKDIR /packmule.io
RUN composer install && bower install --allow-root
# Change working directory to run packmule.io
WORKDIR public

# Expose port 80 
EXPOSE 80

# Run packmule.io
CMD ["php", "-S", "0.0.0.0:80", "index.php"]

