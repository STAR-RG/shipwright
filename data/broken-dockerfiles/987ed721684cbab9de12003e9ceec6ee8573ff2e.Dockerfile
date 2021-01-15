FROM golang:1.8.3

ADD . /go/src/github.com/jonbonazza/huton
RUN go install github.com/jonbonazza/huton

ENTRYPOINT ["/go/bin/huton"]