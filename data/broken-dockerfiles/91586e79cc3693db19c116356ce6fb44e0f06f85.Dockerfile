FROM golang:onbuild
MAINTAINER Masashi Shibata<contact@c-bata.link>

ADD . $GOPATH/src/github.com/c-bata/gosearch
WORKDIR $GOPATH/src/github.com/c-bata/gosearch

RUN godep restore
RUN go install github.com/c-bata/gosearch

# Run the outyet command by default when the container starts.
ENV GOSEARCH_ENV develop
ENTRYPOINT $GOPATH/bin/gosearch

EXPOSE 8080
