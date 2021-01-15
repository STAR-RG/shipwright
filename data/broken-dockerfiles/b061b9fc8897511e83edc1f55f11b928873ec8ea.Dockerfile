FROM golang:1.6.0-alpine
MAINTAINER Siddhartha Basu<siddhartha-basu@northwestern.edu>

RUN set -ex \
    && apk add --no-cache --virtual git \
    && apk add --no-cache --virtual bash \
    && apk add --no-cache --virtual tzdata
COPY go-wrapper /usr/local/bin/
RUN mkdir -p /go/src/app
WORKDIR /go/src/app

# this will ideally be built by the ONBUILD below ;)
CMD ["go-wrapper", "run"]

COPY . /go/src/app
RUN go-wrapper download \
    && go-wrapper install
EXPOSE 9998

ENV TZ America/Chicago
