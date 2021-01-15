FROM golang:1.14.0-alpine3.11

WORKDIR /

COPY ./ ./go/src/github.com/MarioCarrion/nit

RUN CGO_ENABLED=0 GOOS=linux go build --ldflags="-s" -a -installsuffix cgo -o /go/bin/nit ./go/src/github.com/MarioCarrion/nit/cmd/nit
