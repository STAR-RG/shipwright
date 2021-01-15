# Simple usage with a mounted data directory:
# > docker build -t qstarsd .
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.qstarsd:/root/.qstarsd -v ~/.qstarscli:/root/.qstarscli qstarsd qstarsd init
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.qstarsd:/root/.qstarsd -v ~/.qstarscli:/root/.qstarscli qstarsd gstarsd start
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES git bash gcc make libc-dev linux-headers eudev-dev
#make libc-dev bash gcc linux-headers eudev-dev

# Set working directory for the build
WORKDIR /go/src/github.com/QOSGroup/qstars

# Add source files
COPY . .

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apk add --no-cache $PACKAGES && \
#    make tools && \
#    make vendor-deps && \
#    make build && \
#    make install
cd cmd/qstarsd && \
export GOPROXY=http://192.168.1.177:8081 && \
export GO111MODULE=on && \
go build && \
cd ../qstarscli && \
go build 

# Final image
FROM alpine:edge

# Install ca-certificates
#RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/QOSGroup/qstars/cmd/qstarsd/qstarsd /usr/bin/qstarsd
COPY --from=build-env /go/src/github.com/QOSGroup/qstars/cmd/qstarscli/qstarscli /usr/bin/qstarscli

# Run gaiad by default, omit entrypoint to ease using container with gaiacli
CMD ["qstarsd"]

