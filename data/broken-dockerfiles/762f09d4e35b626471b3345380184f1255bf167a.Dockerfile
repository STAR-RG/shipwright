FROM golang:1.6-alpine

RUN apk update && apk add bash git

ADD . /go/src/github.com/golang/scristofari/golang-poll
WORKDIR /go/src/github.com/golang/scristofari/golang-poll

RUN go get github.com/tools/godep
ENV GO15VENDOREXPERIMENT=0
RUN godep get

ENV APP_ENV "dev"
ENV APP_PORT 80
ENV APP_HOST "127.0.0.1"

#RUN go build -o golang-poll .
#ENTRYPOINT ["./golang-poll"]

EXPOSE $APP_PORT


