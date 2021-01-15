FROM alpine
MAINTAINER Ian Bytchek

COPY . /docker
RUN /docker/script/build.sh
EXPOSE 80 443
VOLUME /docker/configuration

ENTRYPOINT ["/docker/script/entrypoint.sh"]
CMD ["nginx-php-fpm"]