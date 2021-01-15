FROM resin/aarch64-ubuntu
RUN apt-get update && apt-get -y install xz-utils libxml2 meson gcc
RUN curl -fsSLO https://github.com/ldc-developers/ldc/releases/download/v1.20.0/ldc2-1.20.0-linux-aarch64.tar.xz \
 && tar xf ldc2-1.20.0-linux-aarch64.tar.xz \
 && sudo cp -rf ldc2-1.20.0-linux-aarch64/* /usr/local \
 && rm -rf ldc*
COPY source source
COPY meson.build meson.build
COPY meson_options.txt meson_options.txt
RUN meson build -D with_test_explicit=true --default-library=static && cd build && ninja test
