FROM golang:1.4.2

RUN mkdir -p /go/src/github.com/calavera/gh-rel /data
WORKDIR /go/src/github.com/calavera/gh-rel

COPY . /go/src/github.com/calavera/gh-rel

RUN go-wrapper download && \
    go-wrapper install

VOLUME ["/data"]

ENTRYPOINT ["/go/bin/gh-rel", "--db=/data/db"]
CMD ["serve"]
