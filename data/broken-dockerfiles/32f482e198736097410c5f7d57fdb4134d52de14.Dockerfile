FROM php:7.2

RUN buildDeps="zlib1g-dev libicu-dev" \
    && apt-get update && apt-get install --no-install-recommends -y git libicu57 $buildDeps && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-install intl zip pcntl mbstring bcmath \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps

RUN echo "date.timezone=UTC" >> $PHP_INI_DIR/php.ini \
 && echo "error_reporting=E_ALL" >> $PHP_INI_DIR/php.ini

COPY --from=composer:1.6 /usr/bin/composer /usr/bin/composer

VOLUME ["/root/.composer/cache"]
