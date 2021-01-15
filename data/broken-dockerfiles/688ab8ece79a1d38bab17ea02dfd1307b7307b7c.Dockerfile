FROM ucalgary/python-librdkafka:3.7.0-0.11.6

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY setup.py /usr/src/app
COPY ftrigger /usr/src/app/ftrigger
COPY wait-for-it.sh /usr/local/bin/wait-for-it
ARG SETUP_COMMAND=install
RUN apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        gcc \
        git \
        libtool \
        make \
        musl-dev && \
    python setup.py ${SETUP_COMMAND} && \
    apk del .build-deps

LABEL maintainer="King Chung Huang <kchuang@ucalgary.ca>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="Function Triggers" \
      org.label-schema.vcs-url="https://github.com/ucalgary/ftrigger"
