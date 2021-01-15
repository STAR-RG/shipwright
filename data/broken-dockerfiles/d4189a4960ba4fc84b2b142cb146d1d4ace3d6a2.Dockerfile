FROM debian:9.4 AS build

RUN apt-get update                                \
    && apt-get install -y --no-install-recommends \
        build-essential                           \
        ca-certificates                           \
        cmake                                     \
        libbsd-dev                                \
        libdaemon-dev                             \
        libcmocka-dev                             \
        libmicrohttpd-dev                         \
        ninja-build                               \
    && rm -rf /var/lib/apt/lists/*

COPY . /src/optics/

WORKDIR /src/optics/build
RUN     cmake .. -G Ninja                         \
     && ninja -C .                                \
     && ctest . -L test                           \
     && ninja -C . install

FROM debian:9.4-slim

RUN apt-get update                                \
    && apt-get install -y --no-install-recommends \
        ca-certificates                           \
        libbsd0                                   \
        libdaemon0                                \
        libmicrohttpd12                           \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build ["/usr/local/lib/liboptics.so",       \
                   "/usr/local/lib/liboptics_static.a"  \
                   "/usr/lib"]
COPY --from=build ["/usr/local/bin/opticsd",            \
                   "/usr/bin/"]

ENTRYPOINT ["/usr/bin/opticsd"]
