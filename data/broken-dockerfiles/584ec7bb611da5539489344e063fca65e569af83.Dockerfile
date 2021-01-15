FROM composer as vendor

COPY . /app

RUN composer install --ignore-platform-reqs -d /app

FROM node:alpine as npm
COPY . /tmp
RUN cd /tmp && npm install && npm run build


FROM shyim/shopware-platform-nginx:php74

COPY --chown=1000:1000 . /var/www/html
COPY --from=vendor --chown=1000:1000 /app/vendor /var/www/html/vendor
COPY --from=npm --chown=1000:1000 /tmp/public /var/www/html/public
