FROM php:7-alpine

RUN docker-php-ext-install opcache

RUN mkdir /srv
RUN mkdir /opcache

RUN echo 'opcache.enable=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo 'opcache.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo 'opcache.validate_timestamps=0' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo 'opcache.file_cache="/opcache"' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
 && echo 'opcache.file_update_protection=0' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN curl -o /srv/index.php https://gist.githubusercontent.com/jderusse/81050a514f2136efabab5ebd520bc598/raw/e7a89c09764088830c2cce117f2f0054927425da/gistfile1.txt \
 && find -L /srv -name '*.php' -exec php -l {} \; -exec sh -c "echo > {}" \;

CMD php /srv/index.php
