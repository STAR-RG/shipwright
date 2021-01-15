FROM golang:1.4

WORKDIR /go/src/app

RUN go get github.com/tools/godep
RUN mkdir -p /go/src/app
COPY . /go/src/app
RUN godep restore

CMD ["godep", "go", "run", "main.go"]

