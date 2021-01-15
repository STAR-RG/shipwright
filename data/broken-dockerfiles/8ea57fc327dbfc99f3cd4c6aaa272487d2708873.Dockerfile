ARG CRYSTAL_VERSION=0.27.2
ARG SHARDS_VERSION=0.8.1


FROM crystallang/crystal:${CRYSTAL_VERSION} AS build
RUN apt-get -qq update && apt-get -y -qq install curl llvm-5.0-dev

# cross-compile crystal:
ARG CRYSTAL_VERSION
ARG CRYSTAL_SOURCE=https://github.com/crystal-lang/crystal/archive/${CRYSTAL_VERSION}.tar.gz
RUN curl -sL ${CRYSTAL_SOURCE} | tar xz -C /tmp
RUN cd /tmp/crystal-${CRYSTAL_VERSION} && make release=1 stats=1 threads=1 \
        FLAGS="--cross-compile --target=x86_64-alpine-linux-musl"


FROM alpine:latest

# build dependencies (will be removed):
RUN apk add --no-cache --virtual .build-deps \
        curl g++ gc-dev libevent-dev llvm5-dev pcre-dev yaml-dev

# crystal runti dependencies:
RUN apk add --no-cache --virtual .crystal-deps \
        gcc gc libc-dev libevent llvm5-libs pcre

# shards runtime dependencies:
RUN apk add --no-cache --virtual .shards-deps \
        gc libevent pcre yaml

# utilities:
RUN apk add make

# pre-install crystal:
ARG CRYSTAL_VERSION
RUN mkdir -p /opt/crystal/bin
COPY --from=build /tmp/crystal-${CRYSTAL_VERSION}/Makefile /opt/crystal/
COPY --from=build /tmp/crystal-${CRYSTAL_VERSION}/.build/crystal.o /opt/crystal/
COPY --from=build /tmp/crystal-${CRYSTAL_VERSION}/src /opt/crystal/src

# link crystal compiler:
RUN cd /opt/crystal && make deps -B
RUN cd /opt/crystal && gcc crystal.o -o bin/crystal \
        -lpthread -lgc -lpcre -levent src/ext/libcrystal.a \
        `llvm-config --libs --ldflags` src/llvm/ext/llvm_ext.o -lstdc++
RUN rm /opt/crystal/crystal.o /opt/crystal/Makefile

# add wrapper script:
COPY crystal.sh /usr/local/bin/crystal
RUN chmod +x /usr/local/bin/crystal

# build/install shards:
ARG SHARDS_VERSION
ARG SHARDS_SOURCE=https://github.com/crystal-lang/shards/archive/v${SHARDS_VERSION}.tar.gz
RUN curl -sL ${SHARDS_SOURCE} | tar xz -C /tmp
RUN cd /tmp/shards-${SHARDS_VERSION} && \
        make CRFLAGS="--release --stats" && \
        mv /tmp/shards-${SHARDS_VERSION}/bin/shards /usr/local/bin/

# copy some static libraries to reduce image size:
RUN set -eux; \
    mkdir -p /opt/crystal/embedded/lib; \
    cp /usr/lib/libgc.a /opt/crystal/embedded/lib/; \
    cp /usr/lib/libevent*.a /opt/crystal/embedded/lib/; \
    cp /usr/lib/libpcre*.a /opt/crystal/embedded/lib/

# cleanup:
RUN apk del .build-deps && \
        rm -rf /tmp/shards-${SHARDS_VERSION} && \
        rm -rf /root/.cache && \
        rm -rf /var/cache/apk/*
