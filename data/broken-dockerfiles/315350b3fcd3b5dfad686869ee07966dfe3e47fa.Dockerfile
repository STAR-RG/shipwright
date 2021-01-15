FROM golang:1.10.3 as golang
WORKDIR $GOPATH/src/github.com/buoyantio/booksapp/traffic
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o /go/bin/simulate-traffic .

FROM alpine:3.7
ENV PATH=$PATH:/go/bin
COPY --from=golang /go/bin /go/bin
ENTRYPOINT ["simulate-traffic"]
