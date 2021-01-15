FROM golang:1.5

RUN mkdir -p $GOPATH/src/github.com/databr/api
WORKDIR $GOPATH/src/github.com/databr/api

COPY . $GOPATH/src/github.com/databr/api

RUN go get github.com/tools/godep
RUN godep restore

RUN go get github.com/pilu/fresh

RUN go build

RUN rm -Rf Godeps

EXPOSE 3000

CMD ["/go/bin/fresh"]
