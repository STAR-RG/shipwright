FROM golang:1.6-alpine
ENTRYPOINT ["/bin/pocker"]

COPY . /src
RUN echo http://dl-4.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    apk add --no-cache git && \
    mkdir -p src/github.com/selimekizoglu/pocker && \
    cp /src/* src/github.com/selimekizoglu/pocker && \
    cd src/github.com/selimekizoglu/pocker && \
    go get -v -d && \
    go test -v && \
    go build -o /bin/pocker && \
    apk del git && \
    rm -rf /go && \
    rm -rf /var/cache/apk/*
