FROM alpine:3.3
MAINTAINER Dustin Blackman

ENV GOROOT /usr/lib/go
ENV GOPATH /gopath
ENV GOBIN /gopath/bin
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

# Deps that rarely change
RUN apk add --update ffmpeg opus bash && \
  rm -rf /usr/share/man /tmp/* /var/tmp/* /var/cache/apk/*

COPY . /gopath/src/github.com/dustinblackman/speakerbot

RUN apk add --update opus-dev git make pkgconfig build-base && \
  apk add go --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted && \
  cd /gopath/src/github.com/dustinblackman/speakerbot && \
  make && \
  mkdir /app && \
  mv ./speakerbot /app/ && \
  apk del go opus-dev git make pkgconfig build-base && \
  rm -rf /usr/share/man /tmp/* /var/tmp/* /var/cache/apk/* /gopath

WORKDIR /app
CMD ["./speakerbot"]
