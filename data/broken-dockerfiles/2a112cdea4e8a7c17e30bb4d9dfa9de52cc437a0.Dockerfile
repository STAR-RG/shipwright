FROM golang:1.11.8 as back_builder

ARG ARCH=amd64
ARG GO111MODULE=on

WORKDIR $GOPATH/src/github.com/supergiant/analyze/

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates

COPY go.mod go.sum vendor $GOPATH/src/github.com/supergiant/analyze/

COPY . $GOPATH/src/github.com/supergiant/analyze/
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build \
		-mod=vendor \
		-o $GOPATH/bin/analyzed \
		-a ./cmd/analyzed

FROM scratch
COPY --from=back_builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=back_builder /go/bin/analyzed /bin/analyzed

ENTRYPOINT ["/bin/analyzed"]
