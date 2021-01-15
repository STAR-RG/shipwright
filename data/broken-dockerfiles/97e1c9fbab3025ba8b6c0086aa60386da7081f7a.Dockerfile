FROM golang:1.10-alpine as builder

RUN apk --no-cache update && apk add git upx

RUN mkdir -p /go/src/github.com/lfdominguez/docker_log_driver_loki
WORKDIR /go/src/github.com/lfdominguez/docker_log_driver_loki
COPY . /go/src/github.com/lfdominguez/docker_log_driver_loki

RUN go get -d -v ./...
RUN env CGO_ENABLED=0 GOOS=linux go build --ldflags '-s -w -extldflags "-static"' -o /usr/bin/docker_log_driver_loki
RUN upx /usr/bin/docker_log_driver_loki

FROM scratch
COPY --from=builder /usr/bin/docker_log_driver_loki /docker_log_driver_loki
CMD ["docker_log_driver_loki"]