FROM golang:alpine as builder

RUN apk add --no-cache --virtual git
COPY / /go/src/github.com/innogames/pirate/
WORKDIR /go/src/github.com/innogames/pirate/
RUN go get ./... && CGO_ENABLED=0 go build -ldflags '-s' -o bin/pirate-server cmd/pirate-server/main.go


FROM scratch

COPY --from=builder /go/src/github.com/innogames/pirate/bin/pirate-server /
COPY /config.yml /etc/pirate/config.yml
EXPOSE 33333
CMD ["/pirate-server"]