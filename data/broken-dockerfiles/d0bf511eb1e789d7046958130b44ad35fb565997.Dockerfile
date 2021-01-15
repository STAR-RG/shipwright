FROM ubuntu:13.10
MAINTAINER Kevin Manley <kevin.manley@gmail.com

RUN apt-get update
RUN apt-get install -y curl git bzr mercurial tree

RUN curl -s https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz | tar -v -C /usr/local/ -xz

ENV PATH  /go/bin:/usr/local/go/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV GOPATH  /go
ENV GOROOT  /usr/local/go

RUN go get github.com/revel/revel
RUN go get github.com/revel/cmd/revel
RUN go get github.com/robfig/cron

ADD . /go/src/github.com/bketelsen/gopheracademy

EXPOSE 80

CMD revel run github.com/bketelsen/gopheracademy prod 80