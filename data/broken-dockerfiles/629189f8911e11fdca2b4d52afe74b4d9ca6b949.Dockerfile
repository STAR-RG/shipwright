# See https://hub.docker.com/_/golang/
# See http://blog.wrouesnel.com/articles/Totally%20static%20Go%20builds/
# build stage
FROM golang:1.8.3-alpine3.6 AS build-env

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh
ENV SRC /go/src/github/agocs/rabbit-mq-stress-tester

ADD *.go $SRC/
RUN cd $SRC && go get ./... && CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /rabbit-mq-stress-tester

# final stage
#FROM scratch
FROM ubuntu
COPY --from=build-env /rabbit-mq-stress-tester /app/
WORKDIR /app
CMD ["./rabbit-mq-stress-tester"]
EXPOSE 7075
