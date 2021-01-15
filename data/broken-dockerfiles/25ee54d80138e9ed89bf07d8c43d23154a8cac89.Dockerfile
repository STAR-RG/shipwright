# Simple usage with a mounted data directory:
# > docker build -t xar .
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.xard:/root/.xard -v ~/.xarcli:/root/.xarcli xar xard init
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.xard:/root/.xard -v ~/.xarcli:/root/.xarcli xar xard start
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python

# Set working directory for the build
WORKDIR /go/src/github.com/xar-network/xar-network

# Add source files
COPY . .

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apk add --no-cache $PACKAGES && \
    make tools && \
    make install

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/xard /usr/bin/xard
COPY --from=build-env /go/bin/xarcli /usr/bin/xarcli

# Run xard by default, omit entrypoint to ease using container with xarcli
CMD ["xard"]
