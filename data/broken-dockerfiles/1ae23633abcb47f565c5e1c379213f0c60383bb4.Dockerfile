FROM golang
WORKDIR /go/src/app
COPY . /go/src/app
RUN go get app
RUN go install app
ENTRYPOINT ["/go/bin/app"]
