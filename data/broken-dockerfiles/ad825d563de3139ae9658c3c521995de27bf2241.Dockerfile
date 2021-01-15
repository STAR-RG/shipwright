FROM alpine:3.9 as base_build

RUN apk add --no-cache\
        git \
        g++ \
        cmake \
        openssl-dev \
        ninja \
        linux-headers
FROM base_build as boost_build

COPY tools/get-boost.sh /root/get-boost.sh

WORKDIR /root
ENV BEAST_LOUNGE_BUILD_TYPE=Release
RUN ./get-boost.sh && cd / && rm -r /root/*

FROM boost_build as build

COPY . /root

RUN cmake -G "Ninja" -H. -Bbuild \
        -DCMAKE_INSTALL_PREFIX=/beast-lounge \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
    && ninja -C build install



FROM alpine:3.9 as deployment

COPY --from=build /beast-lounge /beast-lounge
COPY --from=build /root/tools/docker-run.sh /beast-lounge/bin/docker-run.sh

WORKDIR /beast-lounge

RUN apk add --no-cache \
        libstdc++ \
    && adduser -H -D -g lounge lounge \
    && touch /beast-lounge/var/beast-lounge/log.txt \
    && chown -R lounge:lounge /beast-lounge \
    && chmod 660 /beast-lounge/var/beast-lounge/log.txt \
    && chmod 660 /beast-lounge/etc/beast-lounge/dockerconfig.json

USER lounge

EXPOSE 8080

CMD ["/bin/sh", "/beast-lounge/bin/docker-run.sh", "/beast-lounge/bin/lounge-server", "etc/beast-lounge/dockerconfig.json"]
