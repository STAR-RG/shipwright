
FROM golang:1.8-alpine
MAINTAINER ACM@UIUC

# Get git
RUN apk add --update git bash

# Get dep
RUN  go get -u github.com/golang/dep/...

# Create folder for client key database
RUN mkdir -p /var/groot-api-gateway/

# Bundle app source
ADD . $GOPATH/src/github.com/acm-uiuc/groot-api-gateway
WORKDIR $GOPATH/src/github.com/acm-uiuc/groot-api-gateway

# Download and install external dependencies
RUN dep ensure -vendor-only

# Build groot
RUN ./build.sh

CMD ["./build/groot-api-gateway"]
