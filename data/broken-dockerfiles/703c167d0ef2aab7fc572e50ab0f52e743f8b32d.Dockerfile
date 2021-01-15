ARG PHP_VERSION=7.3.3
ARG GIT_REPO=https://github.com/khs1994-php/tencent-ai.git

FROM khs1994/php:${PHP_VERSION}-composer-alpine

RUN git clone --recursive --depth=1 ${GIT_REPO} /workspace \
    && cd /workspace \
    && composer install -q \
    && composer update -q \
    && composer test
