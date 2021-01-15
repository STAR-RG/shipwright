FROM golang:1.4.2

RUN apt-get update && apt-get install -y libxml2-dev pkg-config

RUN mkdir -p /src/github.com/dynport/dgtk

COPY . /src/github.com/dynport/dgtk

ENV GOPATH /

WORKDIR /src/github.com/dynport/dgtk

RUN make jenkins
