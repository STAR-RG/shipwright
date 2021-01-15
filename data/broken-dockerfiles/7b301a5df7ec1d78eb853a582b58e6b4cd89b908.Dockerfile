FROM golang:1.11.5-alpine AS build-env

LABEL maintainer="Fadi Hadzh <fdhadzh@gmail.com>"

WORKDIR /go/src/github.com/fdhadzh/clickdown

COPY . .

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN go get ./...
RUN go build -v .

FROM alpine:3.8

RUN apk --no-cache add tzdata ca-certificates

WORKDIR /app/clickdown

COPY --from=build-env /go/src/github.com/fdhadzh/clickdown/clickdown /bin/clickdown

ENTRYPOINT [ "clickdown" ]