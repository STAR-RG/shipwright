ARG BASE_IMAGE_TAG

FROM wodby/php-nginx:${BASE_IMAGE_TAG}

COPY templates /etc/gotpl/