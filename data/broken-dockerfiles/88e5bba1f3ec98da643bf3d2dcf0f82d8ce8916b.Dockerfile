FROM golang

ADD . /go/src/github.com/RaiseMe/hermes

WORKDIR /go/src/github.com/RaiseMe/hermes

RUN go get

RUN go install github.com/RaiseMe/hermes

ENTRYPOINT /go/bin/hermes

# Elasticbeanstalk
EXPOSE 80

# Development
EXPOSE 8091
