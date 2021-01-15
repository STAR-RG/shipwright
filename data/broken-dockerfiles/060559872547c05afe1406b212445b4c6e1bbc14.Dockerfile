FROM golang:1.6

RUN go get github.com/gorilla/mux
RUN go get github.com/goji/httpauth
RUN go get github.com/micmonay/keybd_event
RUN go get github.com/mitchellh/gox

# To compile linux/386
RUN apt-get update
RUN apt-get install -y libx32gcc-4.8-dev libc6-dev-i386

WORKDIR /go/src/github.com/odino/touchy

# Gotta compile some C code
ENV CGO_ENABLED=1

CMD gox
