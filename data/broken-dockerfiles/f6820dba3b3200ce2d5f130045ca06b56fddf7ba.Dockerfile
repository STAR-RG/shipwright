FROM nervos/muta:build as builder
WORKDIR /code
COPY . .
RUN cargo build --release

FROM nervos/muta:run
WORKDIR /app
COPY ./config/chain.toml ./config/chain.toml
COPY ./config/genesis.toml ./config/genesis.toml
COPY --from=builder /code/target/release/huobi-chain .
EXPOSE 1337 8000
CMD ["./huobi-chain"]
