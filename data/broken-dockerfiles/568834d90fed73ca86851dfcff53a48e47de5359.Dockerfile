FROM php:7.2-fpm-alpine3.7

#替换国内镜像
COPY deploy/source.list /etc/apk/repositories

RUN apk update && apk --no-cache add freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev curl zlib-dev \
 && docker-php-ext-configure gd \
  --with-gd \
  --with-freetype-dir=/usr/include/ \
  --with-png-dir=/usr/include/ \
  --with-jpeg-dir=/usr/include/ \
  --with-zlib-dir=/usr \
 && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
 && docker-php-ext-install -j${NPROC} gd zip pdo_mysql mbstring \
 && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

ENV COMPOSER_VERSION 1.6.3

RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
 && php composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && php -r "unlink('composer-setup.php');"

WORKDIR /var/www/

CMD ["php-fpm"]