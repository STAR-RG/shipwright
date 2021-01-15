FROM alpine AS builder
RUN apk -U add automake autoconf build-base make
COPY . /src
WORKDIR /src
RUN autoreconf -i && ./configure && make check && make install

FROM alpine
COPY --from=builder /usr/local/bin/jo /bin/jo
ENTRYPOINT ["/bin/jo"]
