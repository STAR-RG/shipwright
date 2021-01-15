# -*- mode: dockerfile -*-
#
# A multi-stage Dockerfile that builds a Linux target then creates a small
# final image for deployment.

#
# STAGE 1
#
# Uses rust-musl-builder to build a release version of the binary targeted for
# MUSL.
#

FROM ekidd/rust-musl-builder AS builder

# Add source code. Note that `.dockerignore` will take care of excluding the
# vast majority of files in the current directory and just bring in the couple
# core files that we need.
ADD ./ ./

# Fix permissions on source code.
RUN sudo chown -R rust:rust /home/rust

# Build the project.
RUN cargo build --release

#
# STAGE 2
#
# Use a tiny base image (alpine) and copy in the release target. This produces
# a very small output image for deployment.
#

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder \
    /home/rust/src/target/x86_64-unknown-linux-musl/release/podcore \
    /
COPY --from=builder \
    /home/rust/src/assets/ \
    /assets/

ENV PORT 8080
ENTRYPOINT ["/podcore"]
