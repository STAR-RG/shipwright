# Build the ray binary
FROM golang:1.12.5 as builder
ENV GOPATH /go
# Copy in the go src
WORKDIR /go/src/github.com/ray-operator
COPY ./    ./

# Build
RUN make ray-controller

# Copy the controller-manager into a thin image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /go/src/github.com/ray-operator/bin/* .
