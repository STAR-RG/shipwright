FROM golang:1.6.2

RUN go get  github.com/golang/lint/golint \
            github.com/mattn/goveralls \
            golang.org/x/tools/cover \
            github.com/aktau/github-release

ENV USER root
WORKDIR /go/src/github.com/HewlettPackard/docker-machine-oneview

COPY . /go/src/github.com/HewlettPackard/docker-machine-oneview
