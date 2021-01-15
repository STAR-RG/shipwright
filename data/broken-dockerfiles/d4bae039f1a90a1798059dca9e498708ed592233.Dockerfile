FROM iryo/alpine

WORKDIR /iryo
COPY . /iryo
RUN rm /iryo/Dockerfile

# FROM golang:1.12-alpine
# RUN apk add --no-cache git
# ARG BIN
# ENV BIN $BIN
# COPY . $GOPATH/src/github.com/iryonetwork/network-poc/
# WORKDIR /go/src/github.com/iryonetwork/network-poc/cmd/$BIN
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /$BIN
#
# # FROM scratch
# # ARG BIN
# # COPY --from=builder /go/src/github.com/iryonetwork/network-poc/cmd/$BIN/$BIN /$BIN
# # COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
