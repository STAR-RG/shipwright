FROM golang:alpine

RUN mkdir -p /go/src/github.com/dunglas/calavera
WORKDIR /go/src/github.com/dunglas/calavera
ADD . /go/src/github.com/dunglas/calavera

RUN apk add -U git

RUN go get -u github.com/kardianos/govendor && \
  govendor sync && \
  govendor install

RUN rm -rf /go/pkg && \
  rm -rf /go/src && \
  rm -rf /go/cache/apk/*

ENTRYPOINT ["/go/bin/calavera"]
