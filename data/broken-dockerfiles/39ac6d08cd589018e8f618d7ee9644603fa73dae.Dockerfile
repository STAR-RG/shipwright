# syntax = docker/dockerfile:1.0-experimental
FROM golang:1.14-alpine3.11 AS build
WORKDIR /go/src/app
RUN apk add --no-cache mailcap make tzdata
ENV TZ=GMT0
RUN mv /usr/share/zoneinfo/${TZ} /etc/localtime
COPY . .
RUN --mount=type=cache,target=~/.cache/go-build CGO_ENABLED=0 make build

FROM alpine:3.11 AS app
ENV GOROOT=/go
RUN apk add --no-cache ca-certificates
COPY --from=build /etc/mime.types /etc/localtime /etc/
COPY --from=build /usr/local/go/lib/time/zoneinfo.zip /go/lib/time/
COPY --from=build /go/src/app/bin /bin/
CMD ["app"]
