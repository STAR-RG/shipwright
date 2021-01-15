# Use this layer for common dependencies
FROM php:7-fpm AS base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install --yes git unzip

ENV COMPOSER_HOME /composer

COPY --from=composer:1.7 /usr/bin/composer /usr/bin/composer

WORKDIR /app

FROM base AS build

# Now install dev dependencies
COPY composer.json /app/
RUN composer install

FROM build AS unit-test

RUN php bin/console test

FROM build AS production

FROM production AS acceptance-tests

RUN composer install --dev
RUN php bin/console acceptance-tests
