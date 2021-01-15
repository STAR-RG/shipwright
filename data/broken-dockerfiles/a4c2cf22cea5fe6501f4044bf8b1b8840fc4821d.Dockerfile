FROM node:10-alpine

ENV DJANGO_SETTINGS_MODULE=mrs.settings
ENV UWSGI_MODULE=mrs.wsgi:application

ENV NODE_ENV=production
ENV PLAYLABS_PLUGINS=postgres,uwsgi,django,sentry
ENV PYTHONIOENCODING=UTF-8 PYTHONUNBUFFERED=1
ENV STATIC_URL=/static/ STATIC_ROOT=/app/static
ENV UWSGI_SPOOLER_NAMES=mail,stat UWSGI_SPOOLER_MOUNT=/app/spooler
ENV VIRTUAL_PROTO=uwsgi
ENV LOG=/app/log
ENV MEDIA_ROOT=/media
ENV ATTACHMENT_ROOT=/mrsattachments
EXPOSE 8000

RUN apk update && apk --no-cache upgrade && apk --no-cache add ca-certificates gettext shadow python3 py3-pillow py3-psycopg2 dumb-init bash git curl uwsgi-python uwsgi-http uwsgi-spooler uwsgi-cache uwsgi-router_cache uwsgi-router_static && pip3 install --upgrade pip
RUN mkdir -p /app && usermod -d /app -l app node && groupmod -n app node && chown -R app:app /app
RUN curl -sL https://sentry.io/get-cli/ | bash
WORKDIR /app

ARG GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT

COPY yarn.lock .babelrc package.json /app/
RUN cd /app && yarn install --cache-folder /dev/shm/yarn --frozen-lockfile
RUN mkdir -p src/mrs
COPY src/mrs/static /app/src/mrs/static
COPY webpack.config.js /app/
RUN yarn prepare

COPY requirements.txt /app/requirements.txt
RUN pip3 install --upgrade -r /app/requirements.txt

COPY setup.py /app/
COPY src /app/src
RUN pip3 install --editable /app

RUN mkdir -p ${LOG}
RUN mkdir -p ${STATIC_ROOT}

RUN mrs collectstatic --noinput --clear

COPY locale /app/locale
RUN mrs compilemessages -l fr

# Pre-compress for uWSGI
RUN find $STATIC_ROOT -type f | xargs gzip -f -k -9

COPY do /app/

RUN mkdir -p ${UWSGI_SPOOLER_MOUNT}/mail ${UWSGI_SPOOLER_MOUNT}/stat $ATTACHMENT_ROOT
RUN touch $ATTACHMENT_ROOT/1x1.png

# Let user write to log
RUN chown -R app. ${LOG} ${UWSGI_SPOOLER_MOUNT} $ATTACHMENT_ROOT
USER app

EXPOSE 6789

CMD /usr/bin/dumb-init bash -euxc "djcli dbcheck && mrs migrate --noinput \
  && uwsgi \
  --spooler=${UWSGI_SPOOLER_MOUNT}/mail \
  --spooler=${UWSGI_SPOOLER_MOUNT}/stat \
  --http-socket=0.0.0.0:8000 \
  --chdir=/app \
  --plugin=python,http,router_static,router_cache \
  --module=$UWSGI_MODULE \
  --http-keepalive \
  --harakiri=120 \
  --max-requests=100 \
  --master \
  --workers=24 \
  --processes=12 \
  --chmod=666 \
  --log-5xx \
  --vacuum \
  --enable-threads \
  --post-buffering=8192 \
  --ignore-sigpipe \
  --ignore-write-errors \
  --disable-write-exception \
  --mime-file /etc/mime.types \
  --thunder-lock \
  --offload-threads '%k' \
  --file-serve-mode x-accel-redirect \
  --route '^/static/.* addheader:Cache-Control: public, max-age=7776000' \
  --static-map $STATIC_ROOT=$STATIC_URL \
  --static-gzip-all \
  --cache2 'name=statcalls,items=100' \
  --static-cache-paths 86400 \
  --static-cache-paths-name statcalls"
