FROM python:3.8.2-alpine as builder


RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update
RUN apk add --upgrade apk-tools

RUN apk add \
    --update alpine-sdk

RUN apk add openssl \
    ca-certificates \
    libxml2-dev \
    postgresql-dev \
    jpeg-dev \
    libffi-dev \
    linux-headers \
    python3-dev \
    libxslt-dev \
    xmlsec-dev


RUN apk add --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    gcc \
    g++

RUN pip install --upgrade \
    setuptools \
    pip \
    wheel \
    pipenv

WORKDIR /rapidpro_community_portal/
ADD Pipfile .
ADD Pipfile.lock .
RUN pipenv install --system  --ignore-pipfile --deploy


FROM python:3.8.2-alpine

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update
RUN apk add --upgrade apk-tools
RUN apk add postgresql-client \
    openssl \
    ca-certificates \
    libxml2-dev \
    jpeg

ADD src /code/

WORKDIR /code/


COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

ENV UWSGI_PROTOCOL=http \
    UWSGI_WORKERS=4 \
    UWSGI_AUTO_PROCNAME=true \
    UWSGI_BUFFER_SIZE=32768 \
    UWSGI_DIE_ON_TERM=true \
    UWSGI_DISABLE_LOGGING=false \
    UWSGI_DISABLE_WRITE_EXCEPTION=true \
    UWSGI_FREEBIND=true \
    UWSGI_HARAKIRI=180 \
    UWSGI_HTTP_TIMEOUT=180 \
    UWSGI_IGNORE_SIGPIPE=true \
    UWSGI_IGNORE_WRITE_ERRORS=true \
    UWSGI_LIMIT_POST=20971520 \
    UWSGI_LOG_X_FORWARDED_FOR=false \
    UWSGI_MEMORY_REPORT=true \
    UWSGI_NEED_APP=true \
    UWSGI_POST_BUFFERING=65536 \
    UWSGI_PROCNAME_PREFIX_SPACED="[RapidproCommunityPortal]" \
    UWSGI_RELOAD_ON_RSS=600 \
    UWSGI_THREADS=4 \
    UWSGI_THUNDER_LOCK=true \
    UWSGI_VACUUM=true \
    UWSGI_MODULE="rapidpro_community_portal.config.wsgi:application" \
    UWSGI_HTTP_SOCKET=0.0.0.0:8000 \
    UWSGI_MASTER=true \
    UWSGI_ENABLE_THREADS=true \
    UWSGI_LAZY_APPS=true \
    UWSGI_SINGLE_INTERPRETER=true

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/code \
    DJANGO_SETTINGS_MODULE=rapidpro_community_portal.config.settings

RUN DATABASE_URL='psql://postgres:pass@db:5432/postgres' django-admin collectstatic --noinput
EXPOSE 8000
