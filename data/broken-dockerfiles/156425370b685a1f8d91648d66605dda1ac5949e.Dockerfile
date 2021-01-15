################################################################################
# Base image
################################################################################

FROM balenalib/%%BALENA_MACHINE_NAME%%-debian as base

ENV DEBIAN_FRONTEND=noninteractive

################################################################################
# Rust image
################################################################################

FROM base as rust

# Install build tools
RUN apt-get -q update && apt-get install -yq --no-install-recommends build-essential curl file

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=923479
# https://github.com/balena-io-library/base-images/issues/562
RUN c_rehash

ENV PATH=/root/.cargo/bin:$PATH

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain 1.37.0 -y

################################################################################
# Dependencies
################################################################################

FROM rust as dependencies

WORKDIR /build

# Create new fake project ($USER is needed by `cargo new`)
RUN USER=root cargo new app

WORKDIR /build/app

# Copy real app dependencies
COPY Cargo.* ./

# Build fake project with real dependencies
RUN cargo build --release

# Remove the fake app build artifacts
#
# NOTE If your application name contains `-` (`foo-bar` for example)
# then the correct command to remove build artifacts looks like:
#
# RUN rm -rf target/release/foo-bar target/release/deps/foo_bar-*
#                              ^                           ^
RUN rm -rf target/release/hello* target/release/deps/hello-*

################################################################################
# Builder
################################################################################

FROM rust as builder

# We do not want to download deps, update registry, ... again
COPY --from=dependencies /root/.cargo /root/.cargo

WORKDIR /build/app

# Copy everything, not just source code
COPY . .

# Update already built deps from dependencies image
COPY --from=dependencies /build/app/target target

# Build real app
RUN cargo build --release

################################################################################
# Final image
################################################################################

FROM base

WORKDIR /app

# Copy binary from builder image
COPY --from=builder /build/app/target/release/hello .

# Copy other folders required by the application. Example:
# COPY --from=builder /build/app/assets assets

# Launch application
CMD ["./hello", "%%BALENA_MACHINE_NAME%%"]
