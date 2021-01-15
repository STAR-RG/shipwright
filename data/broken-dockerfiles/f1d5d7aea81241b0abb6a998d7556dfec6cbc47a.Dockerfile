FROM python:3-alpine

RUN apk add --no-cache nginx supervisor

ADD . /app
WORKDIR /app

RUN apk add --no-cache nodejs \
 && npm install \
 && npm run build \
 && rm -rf node_modules \
 && apk del nodejs

RUN apk add --no-cache --virtual build-dep gcc linux-headers libc-dev \
 && apk add --no-cache jpeg-dev zlib-dev \
 && pip install -r /app/requirements.txt \
 && apk del build-dep

EXPOSE 80

CMD /usr/bin/supervisord -c /app/docker/supervisor.conf
