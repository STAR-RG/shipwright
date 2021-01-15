FROM golang:1.9.4-alpine3.6 AS builder

RUN apk add --update git
RUN go get -u github.com/kardianos/govendor
WORKDIR /go/src/github.com/bobbytables/spinnaker-datadog-bridge
COPY . .

RUN govendor sync
RUN go build -o /spinnaker-dd-bridge ./cmd/spinnaker-dd-bridge

FROM alpine:3.6
MAINTAINER Robert Ross <robert@creativequeries.com>

RUN apk add --update ca-certificates
WORKDIR /usr/local/bin
COPY --from=builder /spinnaker-dd-bridge .

CMD ["spinnaker-dd-bridge"]
