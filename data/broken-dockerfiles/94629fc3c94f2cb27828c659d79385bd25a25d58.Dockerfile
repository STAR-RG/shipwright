# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang

# Copy the local package files to the container's workspace.
ADD . /go/src/github.com/haukurk/latency-microservice-go

# Build the outyet command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN go get github.com/haukurk/latency-microservice-go/cmd/latency-server
RUN go install github.com/haukurk/latency-microservice-go/cmd/latency-server

# Run the outyet command by default when the container starts.
ENTRYPOINT /go/bin/latency-server --config /go/src/github.com/haukurk/latency-microservice-go/config.json server

# Document that the service listens on port 7801.
EXPOSE 7801 
