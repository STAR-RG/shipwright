FROM koteeq/tdlib:latest as tdlib


FROM golang:alpine as builder
RUN apk update && apk add --no-cache git gcc musl-dev zlib-dev openssl-dev g++
RUN adduser -D -g '' appuser

COPY --from=tdlib /tdlib/ /usr/local/

WORKDIR $GOPATH/src/github.com/aprosvetova/nameskeeperbot
COPY . .

RUN go get -d -v
RUN go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/app .


FROM alpine
RUN apk update && apk add --no-cache g++

COPY --from=builder /go/bin/app /go/bin/app

VOLUME ["/data"]
ENTRYPOINT ["/go/bin/app"]