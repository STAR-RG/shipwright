FROM alpine:3.4
MAINTAINER Chris <c@crccheck.com>

ENV REQUESTBIN_VERSION master

ADD https://github.com/Runscope/requestbin/archive/${REQUESTBIN_VERSION}.zip /


RUN unzip ${REQUESTBIN_VERSION}.zip && \
      rm ${REQUESTBIN_VERSION}.zip && \
      mv requestbin-${REQUESTBIN_VERSION} /app

RUN apk add --update \
      gcc python python-dev py-pip \
      # greenlet
      musl-dev \
      # sys/queue.h
      bsd-compat-headers \
      # event.h
      libevent-dev \
      && rm -rf /var/cache/apk/*

WORKDIR /app

RUN pip install --quiet --disable-pip-version-check -r requirements.txt

# must enable REALM=prod to load REDIS_URL
ENV REALM prod
RUN sed -i 's/DEBUG = False/DEBUG = True/' requestbin/config.py

ENV PORT 80
EXPOSE 80

# Have to use this format to use $PORT environment variable
CMD gunicorn --bind=0.0.0.0:$PORT --worker-class=gevent --workers=2 --max-requests=1000 requestbin:app
