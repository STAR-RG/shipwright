ARG BASE_IMAGE_TAG

FROM wodby/php-nginx:${BASE_IMAGE_TAG}

ARG DRUPAL_VER

ENV DRUPAL_VER="${DRUPAL_VER}"

COPY templates/d${DRUPAL_VER}-vhost.conf.tpl /etc/gotpl/vhost.conf.tpl