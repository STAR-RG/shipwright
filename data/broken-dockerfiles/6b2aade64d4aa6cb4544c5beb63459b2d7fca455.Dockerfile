FROM python:3.5-alpine
MAINTAINER "Joan Fuster" <joan.fuster@gmail.com>

COPY . /code

RUN set -ex && \
    apk add --no-cache ca-certificates && \
    cd /code && \
    python setup.py install && \
    cd .. && \
    mkdir /data && \
    rm -fr /code

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/compose2fleet"]
CMD ["-h"]
