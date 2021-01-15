FROM golang:1.11.2-alpine AS build
WORKDIR /go/src/github.com/kramphub/kiya/
COPY . .
ARG version
RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.version=$version" .

FROM alpine
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY --from=build /go/src/github.com/kramphub/kiya /usr/bin/
ENTRYPOINT ["/usr/bin/kiya"]
