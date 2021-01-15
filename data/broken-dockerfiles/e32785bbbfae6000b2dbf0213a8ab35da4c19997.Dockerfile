FROM alpine:edge

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

COPY . /cart-build

RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk update && apk upgrade \
    && apk add --update --no-cache \
      opencv@testing \
      opencv-dev@testing \
      clang-libs \
    && apk add --update --no-cache \
      --virtual .build-deps \
      build-base \
      unzip \
      wget \
      cmake \
      clang-dev \
    && ln -s /dev/null /dev/raw1394 \
    # Build cart
    && cd /cart-build && mkdir build && cd build \
    && cmake -D CMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j"$(nproc)" \
    && make install \
    # Cleanup
    && rm -rf /cart-build \
    && rm -rf /tmp/* \
    && apk del --purge opencv-dev \
    && apk del --purge .build-deps \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/local/bin/cart"]
