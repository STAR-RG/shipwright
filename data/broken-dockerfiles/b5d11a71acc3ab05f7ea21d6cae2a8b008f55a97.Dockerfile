FROM golang:1.5

COPY . /go/src/github.com/remeh/upd

RUN go get github.com/mattn/gom \
    && cd /go/src/github.com/remeh/upd \
    && gom install \
    && gom build bin/server/server.go

EXPOSE 9000

ENTRYPOINT ["/go/src/github.com/remeh/upd/server"]
CMD ["-c", "/etc/upd/server.conf"]
