FROM golang:1.4

RUN go get github.com/tools/godep

RUN mkdir -p /go/src/github.com/farmer-project/farmer
WORKDIR /go/src/github.com/farmer-project/farmer
ADD . /go/src/github.com/farmer-project/farmer

RUN godep get

EXPOSE 80
CMD ["go", "run", "main.go"]