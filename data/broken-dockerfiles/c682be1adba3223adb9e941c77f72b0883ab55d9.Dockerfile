FROM golang:1.10

WORKDIR /go/src/github.com/patrobinson/go-fish
COPY . /go/src/github.com/patrobinson/go-fish
RUN make build
