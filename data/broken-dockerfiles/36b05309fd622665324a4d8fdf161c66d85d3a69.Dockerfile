FROM frolvlad/alpine-python3

WORKDIR /app

COPY requirements.txt /app/

# RUN apk add --no-cache \
#   --virtual=.build-dependencies \
#   g++ gfortran file binutils \
#   musl-dev python3-dev openblas-dev && \
#   apk add libstdc++ openblas && \
#   ln -s locale.h /usr/include/xlocale.h && \
#   pip install -r /app/requirements.txt && \
#   rm -r /root/.cache && \
#   find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
#   find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
#   rm /usr/include/xlocale.h && \
#   apk del .build-dependencies
RUN apk add --no-cache \
  --virtual=.build-dependencies \
  build-base python3-dev file && \
  apk add --no-cache jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev \
  tiff-dev tk-dev tcl-dev && \
  ln -s locale.h /usr/include/xlocale.h && \
  pip install -r /app/requirements.txt && \
  rm -r /root/.cache && \
  find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
  find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
  rm /usr/include/xlocale.h && \
  apk del .build-dependencies

COPY . /app

RUN ln -s /bin/sh /bin/bash

ENV DJANGO_PORT=8000 \
  DJANGO_LOG=$PWD \
  DJANGO_DB_HOST=vod_db \
  TSRTMP_DB_HOST=vod_db \
  NAME="mysite_app" \
  # Name of the application
  ADDRESS=0.0.0.0 \
  LOG_DIR=logs \
  ERROR_LOG=error.log \
  PID_FILE=logs/vod.pid \
  NUM_WORKERS=4 \
  # how many worker processes should Gunicorn spawn
  TIME_OUT=900000 \
  #set time out!!!!!
  DJANGO_SETTINGS_MODULE=mysite.settings \
  # which settings file should Django use
  DJANGO_WSGI_MODULE=mysite.wsgi
  # WSGI module name

RUN apk add --no-cache curl
HEALTHCHECK --interval=30s --timeout=3s CMD curl -fs http://localhost:$DJANGO_PORT/admin || exit 1

EXPOSE 8000

ENTRYPOINT ["sh", "entrypoint.sh"]

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
