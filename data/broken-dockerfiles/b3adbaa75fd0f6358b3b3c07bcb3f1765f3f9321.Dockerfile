FROM rust:1.23.0
COPY bin/init-langserver /bin/init-langserver
COPY Cargo.toml /langserver/Cargo.toml
COPY src /langserver/src
WORKDIR /langserver
RUN cargo build --release
