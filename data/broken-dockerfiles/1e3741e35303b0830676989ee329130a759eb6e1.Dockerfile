FROM php:fpm-alpine

RUN rm -rf /usr/local/etc/php-fpm.d/docker.conf \
           /usr/local/etc/php-fpm.d/www.conf \ 
           /usr/local/etc/php-fpm.d/www.conf.default \
           /usr/local/etc/php-fpm.d/zz-docker.conf && \
           docker-php-ext-install bcmath mbstring && \
           apk add --no-cache sudo iputils supervisor && \
           apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ hping3 && \
           adduser -S app && \
           echo 'app ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /app

COPY ./phpfpm.conf /usr/local/etc/php-fpm.d/worker.conf

ENTRYPOINT ["supervisord"]
CMD ["--nodaemon", "--configuration", "/app/supervisord.conf"]

COPY ./ /app 