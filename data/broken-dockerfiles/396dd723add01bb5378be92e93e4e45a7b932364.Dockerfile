# STEP 1 build executable binary
FROM golang:alpine as builder
COPY . $GOPATH/src/git.gits.id/go-iris-mv/
WORKDIR $GOPATH/src/git.gits.id/go-iris-mv/

# Get dependencies
RUN dep ensure -update

# Build the binary
RUN go build -o /go/bin/main

# STEP 2 build a small image
# Start from scratch
FROM scratch

# Copy our static executable
COPY --from=builder /go/bin/main /go/bin/main
ENTRYPOINT ["/go/bin/hello"]