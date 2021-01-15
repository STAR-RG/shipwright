FROM ubuntu:16.04

ENV GOPATH /go

RUN apt-get update && apt-get install -y \
  llvm \
  clang \
  git \
  golang \
  linux-headers-$(uname -r)

RUN mkdir -p /src /go

RUN go get -u github.com/jteeuwen/go-bindata/... && \
  mv $GOPATH/bin/go-bindata /usr/local/bin
