FROM alpine:edge
MAINTAINER Thibault NORMAND <me@zenithar.org>

ENV GOPATH /go
ENV CADDY_TAG v0.10.4

RUN apk add --update musl \
    && apk add -t build-tools build-base go mercurial git \
    && mkdir /go \
    && cd /go \
    && go get -tags=$CADDY_TAG github.com/mholt/caddy/... \
    && mv $GOPATH/bin/caddy /bin \
    && mkdir /caddy \
    && apk del --purge build-tools \
    && rm -rf /go /var/cache/apk/*

EXPOSE     2015
VOLUME     [ "/caddy" ]
WORKDIR    "/caddy"
ENTRYPOINT [ "/bin/caddy" ]
CMD        [ "-conf='/caddy/Caddyfile'" ]
