FROM golang:1.11.0
WORKDIR /go/src/github.com/nyu-distributed-systems-fa18/algorand/server
COPY server .
COPY pb ../pb

RUN go get -v ./...
RUN go install -v ./...

EXPOSE 3000 3001
CMD ["server"]
