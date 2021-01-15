FROM golang

MAINTAINER Abhi Yerra <abhi@berkeley.edu>

ADD . /go/src/github.com/abhiyerra/sarpa

RUN cd /go/src/github.com/abhiyerra/sarpa && go get ./...
RUN go install github.com/abhiyerra/sarpa

WORKDIR /go/src/github.com/abhiyerra/sarpa

ENTRYPOINT /go/bin/sarpa