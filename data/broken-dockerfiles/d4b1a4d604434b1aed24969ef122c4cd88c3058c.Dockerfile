FROM rust:1.26.0

RUN apt-get update

WORKDIR /app
ADD . /app

ARG GOOGLE_CLOUD_PLATFORM_API_KEY
ARG OXFORD_API_ID
ARG OXFORD_API_KEY

RUN cargo build --release --bin server && \
  mkdir -p /app/bin && \
  mv /app/target/release/server /app/bin/server && \
  cargo clean

EXPOSE 3000

CMD ["/app/bin/server"]
