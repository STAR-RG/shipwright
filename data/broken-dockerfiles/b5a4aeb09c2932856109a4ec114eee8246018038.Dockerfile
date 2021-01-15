FROM golang:latest
ADD . $GOPATH/src/github.com/serulian/compiler/.
WORKDIR $GOPATH/src/github.com/serulian/compiler/.
RUN go get -v ./...
WORKDIR $GOPATH/src/github.com/serulian/compiler/cmd/serulian/
RUN go build -o /cmd/serulian .
ENTRYPOINT ["/cmd/serulian"]