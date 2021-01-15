FROM golang:1.12 AS builder
WORKDIR /go/src/github.com/joelspeed/webhook-certificate-generator
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/wcg github.com/joelspeed/webhook-certificate-generator/cmd/webhook-certificate-generator

FROM scratch
COPY --from=builder /bin/wcg /bin/wcg

ENTRYPOINT ["/bin/wcg"]
