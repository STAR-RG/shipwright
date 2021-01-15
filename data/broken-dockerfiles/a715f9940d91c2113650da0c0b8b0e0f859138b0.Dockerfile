FROM golang:1-alpine as build 

ENV NERD_PATH /go/src/github.com/nerdalize/nerd

ADD . $NERD_PATH

RUN mkdir /in; mkdir /out

# Leave these go build flags, this way we can inject the nerd binary in other containers
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH amd64
RUN cd $NERD_PATH; \
    go build \
      -ldflags "-X main.version=$(cat VERSION) -X main.commit=docker.build" \
      -o /go/bin/nerd \
      main.go

FROM alpine:3.5
COPY --from=build /go/bin/nerd /go/bin/nerd
ENTRYPOINT ["/go/bin/nerd"]
