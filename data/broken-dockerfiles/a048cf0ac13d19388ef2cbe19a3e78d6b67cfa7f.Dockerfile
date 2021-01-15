#########################################
# Build stage
#########################################
FROM golang:1.13 AS builder

# Repository location
ARG REPOSITORY=github.com/ncarlier

# Artifact name
ARG ARTIFACT=feedpushr

# Copy sources into the container
ADD . /go/src/$REPOSITORY/$ARTIFACT

# Set working directory
WORKDIR /go/src/$REPOSITORY/$ARTIFACT

# Build the binary
RUN make build plugins

#########################################
# Distribution stage
#########################################
FROM debian:stable-slim

# Repository location
ARG REPOSITORY=github.com/ncarlier

# Artifact name
ARG ARTIFACT=feedpushr

# Install project files
COPY --from=builder /go/src/$REPOSITORY/$ARTIFACT/release/ /usr/local/share/$ARTIFACT/

# Update certificates
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates \
    && apt-get clean -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates --fresh

# Install binary
RUN ln -s /usr/local/share/$ARTIFACT/$ARTIFACT /usr/local/bin/$ARTIFACT

# Define working directory
WORKDIR /usr/local/share/$ARTIFACT

# Define command
CMD feedpushr

