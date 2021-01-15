FROM php:7.3.3-fpm-alpine3.9 AS base

RUN apk update \
    && apk add nginx \
    && apk add gettext

# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"

RUN docker-php-ext-install opcache

# Images should install their own site specific config
RUN rm /etc/nginx/conf.d/*
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/nginx-site.template /etc/nginx/conf.d/
COPY ./docker/run_app.sh /etc/run_app.sh

###################################################################################
# Has all the files AND composer installed constructs everything needed for the app
FROM base AS builder
WORKDIR /app

# Used by the test watcher
RUN apk add entr

# Composer needs git and some zip deps
RUN apk add git libzip-dev
RUN docker-php-ext-install zip
COPY ./docker/install_composer.sh /tmp/install_composer.sh
RUN /tmp/install_composer.sh && rm /tmp/install_composer.sh

# Install the dependencies
COPY ./composer.* /app/
RUN php composer.phar install

# Copy over our app code
COPY  ./www /app/www/
COPY  ./src /app/src/

###################################################################################
# Uses the base to build everything prod needs
FROM builder AS prod-source

# We make a nice index.html file built from the README
COPY ./scripts /app/scripts
COPY ./README.md /app
RUN php /app/scripts/build_index.php \
 && rm README.md \
 && rm -rf scripts/

# None of the dev dependencies are needed by this point
RUN rm -rf vendor/ \
 && php composer.phar install --no-dev \
 && php composer.phar dump-autoload --no-dev

# The built image doesnt need composer
RUN rm composer.*

###################################################################################
# This is the final image that we'll serve from
FROM base AS prod
WORKDIR /app
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini

# The builder has already pulled all composer deps & built the autoloader
COPY --from=prod-source /app /app

EXPOSE $PORT
CMD ["/etc/run_app.sh"]
HEALTHCHECK CMD curl -f http://localhost:${PORT}/health-check || exit 1