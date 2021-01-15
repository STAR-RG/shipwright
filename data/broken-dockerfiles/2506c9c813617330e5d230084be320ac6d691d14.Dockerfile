FROM alpine:edge as build
RUN    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk update \
    && apk add wget ghc ca-certificates musl-dev shadow linux-headers zlib-dev \
    && update-ca-certificates
RUN wget -qO- https://get.haskellstack.org/ | sh
RUN adduser -h /home/stack stack -D
USER stack
RUN    stack config set system-ghc --global true \
    && mkdir -p /home/stack/.stack/global-project/ \
    && echo 'resolver: lts-8.8' > /home/stack/.stack/global-project/stack.yaml \
    && stack setup
USER root

RUN mkdir /build
COPY stack.yaml /build
RUN    cd /build \
    && sed -i 's/enable: true/enable: false/' stack.yaml \
    && stack config set system-ghc --global true \
    && stack setup
COPY crocker.cabal /build
RUN cd /build \
    && stack build --dependencies-only --test
COPY . /build
RUN cd /build \
    && sed -i 's/enable: true/enable: false/' stack.yaml \
    && stack build --test \
    && stack install

FROM scratch

COPY --from=build /root/.local/bin/crocker /
