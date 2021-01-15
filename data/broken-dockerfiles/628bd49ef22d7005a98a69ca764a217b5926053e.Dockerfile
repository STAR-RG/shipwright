FROM golang:1.4
MAINTAINER tobe tobeg3oogle@gmail.com

RUN go get github.com/astaxie/beego

ADD . /go/src/github.com/tobegit3hub/ceph-web
WORKDIR /go/src/github.com/tobegit3hub/ceph-web
RUN go build

EXPOSE 8080

CMD ./ceph-web