FROM golang:1.11-alpine

ENV CGO_ENABLED=0

WORKDIR /go/src/github.com/blend/go-sdk

RUN apk update && \
	apk upgrade && \
	apk add git

ADD . /go/src/github.com/blend/go-sdk

RUN go get ./...

ENTRYPOINT go test ./...
