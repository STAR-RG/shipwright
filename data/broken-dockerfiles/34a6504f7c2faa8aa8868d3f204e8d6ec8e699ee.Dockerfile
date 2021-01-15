FROM php:7-fpm
MAINTAINER Marcin Kurzyna <m.kurzyna@gmail.com>

# vary build on task version; if undefined minimal required is 2.5.0
# update version through build args (inline or through docker-compose.yml)
ARG TASKWARRIOR_VER
ENV TASKWARRIOR_VER ${TASKWARRIOR_VER:-2.5.0}

# provide PHP & build dependencies
RUN apt-get update && apt-get install -y \
        make cmake gcc tar \
        libgnutls28-dev uuid-dev \
        zlib1g-dev \
        libmcrypt-dev \
        libssl-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt zip

# provide task
RUN mkdir -p /tmp/task-src && cd /tmp/task-src && \
	curl -sS https://taskwarrior.org/download/task-${TASKWARRIOR_VER}.tar.gz | tar -xz --strip-components=1 && \
	cmake -DCMAKE_BUILD_TYPE=release . && \
	make all install clean

# provide composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer

# setup user run permissions
RUN chown www-data:www-data /var/www
USER www-data

# add entrypoint
COPY ./bin/entrypoint.php.sh /entrypoint.php.sh
ENTRYPOINT /entrypoint.php.sh
