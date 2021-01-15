#
# Multi-stage build
# build image using debian:latest
#
FROM debian:latest AS builder
ARG GITHUB_CREDENTIALS

RUN apt-get update && apt-get -y install wget git build-essential golang-1.8

RUN ln -fs /usr/lib/go-1.8/bin/go /usr/bin/go

# FIXME: all this should be in the subproject.
WORKDIR /build
RUN wget https://github.com/cisco/libsrtp/archive/v2.1.0.tar.gz && tar xvfz v2.1.0.tar.gz
RUN wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_0f.tar.gz && tar xvfz OpenSSL_1_1_0f.tar.gz
RUN git clone --depth 1 -b2.54.0 https://github.com/GNOME/glib
RUN git clone --depth 1 -b1.14.0 https://github.com/GStreamer/gstreamer
RUN git clone --depth 1 -b1.14.0 https://github.com/GStreamer/gst-plugins-base
RUN git clone --depth 1 -borc-0.4.27 https://github.com/GStreamer/orc
RUN git clone --depth 1 -b1.14.0 https://github.com/GStreamer/gst-plugins-good
RUN git clone --depth 1 -b1.14.0 https://github.com/GStreamer/gst-plugins-bad
RUN git clone --depth 1 -b1.14.0 https://github.com/GStreamer/gst-plugins-ugly
RUN git clone --depth 1 -b1.14.0 https://github.com/GStreamer/gst-libav

WORKDIR /build/openssl-OpenSSL_1_1_0f
RUN ./config --prefix=/usr/local && make -j$(nproc) && make install
WORKDIR /build/libsrtp-2.1.0
RUN ./configure --prefix=/usr/local && make -j$(nproc) && make install

RUN apt-get update

#
WORKDIR /build/glib
RUN apt-get install -y dh-autoreconf
RUN apt-get install -y libffi-dev
RUN apt-get install -y libmount-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y gtk-doc-tools
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local
RUN make -j$(nproc) && make install

WORKDIR /build/gstreamer
RUN apt-get install -y libbison-dev
RUN apt-get install -y flex
RUN ./autogen.sh --prefix=/usr/local --disable-examples --disable-tests --disable-failing-tests --disable-benchmarks --disable-gtk-doc-html
RUN make -j$(nproc) && make install

WORKDIR /build/orc
RUN ./autogen.sh --prefix=/usr/local --disable-gtk-doc-html
RUN make -j$(nproc) && make install

# FIXME: move up
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
RUN echo "/usr/local/lib/gstreamer-1.0" >> /etc/ld.so.conf.d/local.conf
RUN /sbin/ldconfig

WORKDIR /build/gst-plugins-base
RUN apt-get install -y libopus-dev
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local
RUN make -j$(nproc) && make install

WORKDIR /build/gst-plugins-good
RUN apt-get install -y libvpx-dev
RUN ./autogen.sh --prefix=/usr/local --disable-gtk-doc-html
RUN make -j$(nproc) && make install

RUN apt-get install -y nasm
WORKDIR /build
RUN git clone https://github.com/cisco/openh264
WORKDIR /build/openh264
RUN make -j$(nproc) -j4 && make install

WORKDIR /build/gst-plugins-bad
RUN apt-get install -y libvo-aacenc-dev
RUN wget http://fr.archive.ubuntu.com/ubuntu/pool/multiverse/f/faac/libfaac0_1.28+cvs20151130-1_amd64.deb
RUN wget http://fr.archive.ubuntu.com/ubuntu/pool/multiverse/f/faac/libfaac-dev_1.28+cvs20151130-1_amd64.deb
RUN dpkg -i libfaac0_1.28+cvs20151130-1_amd64.deb libfaac-dev_1.28+cvs20151130-1_amd64.deb
RUN apt-get install -y libopencv-dev
RUN ./autogen.sh --prefix=/usr/local --disable-gtk-doc --disable-gtk-doc-html --disable-hls
RUN make -j$(nproc) && make install

WORKDIR /build/gst-plugins-ugly
RUN apt-get install -y libx264-dev
RUN ./autogen.sh --prefix=/usr/local --disable-gtk-doc --disable-gtk-doc-html
RUN make -j$(nproc) && make install

WORKDIR /build/gst-libav
RUN ./autogen.sh --prefix=/usr/local --disable-gtk-doc --disable-gtk-doc-html
RUN make -j$(nproc) && make install

WORKDIR /build
RUN git clone -b1.0.6 https://github.com/intel/cmrt.git
RUN git clone -b2.1.0 https://github.com/intel/libva.git
RUN git clone -b1.0.2 https://github.com/01org/intel-hybrid-driver.git
RUN git clone -b2.1.0 https://github.com/intel/intel-vaapi-driver.git
RUN git clone -b2.1.0 https://github.com/intel/libva-utils.git
RUN apt-get install -y libdrm-dev libudev-dev
WORKDIR /build/libva
RUN ./autogen.sh && make install
WORKDIR /build/cmrt
RUN ./autogen.sh && make install
WORKDIR /build/intel-hybrid-driver
RUN ./autogen.sh && make install
WORKDIR /build/intel-vaapi-driver
RUN ./autogen.sh --enable-hybrid-codec && make install
WORKDIR /build/libva-utils
RUN ./autogen.sh && make install

WORKDIR /build
RUN git clone --depth 1 -b1.12.5 https://github.com/GStreamer/gstreamer-vaapi
WORKDIR /build/gstreamer-vaapi
RUN apt-get install -y libva-dev libudev-dev
RUN ./autogen.sh --prefix=/usr/local --disable-gtk-doc --disable-gtk-doc-html
RUN make -j$(nproc) && make install

RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/mcu.conf
RUN echo "/usr/local/lib/gstreamer-1.0" >> /etc/ld.so.conf.d/mcu.conf
RUN ldconfig -vvvvv

#
WORKDIR /go/src/app

# prepare gopaths directories
RUN mkdir -p /vol-gopath-versioned
RUN mkdir -p /vol-gopath-unversioned

# setup GOPATH
ENV GOPATH=/vol-gopath-unversioned:/vol-gopath-versioned:/go

# install hot reload module
RUN /usr/lib/go-1.8/bin/go get github.com/pilu/fresh

RUN ln -fs /usr/lib/go-1.8/bin/go /usr/bin/go

# go will need to download code from private github repositories
RUN echo '[url "https://'$GITHUB_CREDENTIALS'@github.com/"]' >> /root/.gitconfig
RUN echo '\tinsteadOf = git://github.com/' >>  /root/.gitconfig
RUN echo '[url "https://'$GITHUB_CREDENTIALS'@github.com/"]'   >>  /root/.gitconfig
RUN echo '\tinsteadOf = https://github.com/'  >>  /root/.gitconfig

# build
ENV CGO_CFLAGS -pthread -I/usr/local/include/gstreamer-1.0 -I/usr/local/include/glib-2.0 -I/usr/local/lib/glib-2.0/include -I/usr/local/include
ENV CGO_LDFLAGS -L/usr/local/lib -lcrypto -lssl -lsrtp2  -L/usr/local/lib -lgstreamer-1.0 -lgobject-2.0 -lglib-2.0 -lgstapp-1.0

# hacky: dtls, gst, rtcp, sdp, srtp should be in the "master" or their own github.com/...
#  until it exists, we need to "copy" them inside the image
#  because go get will not be able to fetch these dependencies
RUN mkdir -p /vol-gopath-versioned/src/github.com/heytribe/live-webrtcsignaling
COPY . /vol-gopath-versioned/src/github.com/heytribe/live-webrtcsignaling

# copy src
COPY . .

COPY ./go-wrapper /usr/bin/
RUN chmod 755 /usr/bin/go-wrapper

# download dependencies & build app
RUN go-wrapper download && \
    go-wrapper install && \
    go build

CMD /vol-gopath-unversioned/bin/fresh

#
# Multi-stage build
# prodable image
#
FROM debian:latest AS base
WORKDIR /go/src/app
COPY --from=builder /usr/local/lib/gstreamer-1.0/libgstvpx.so /usr/local/lib/gstreamer-1.0/libgstopus.so /usr/local/lib/gstreamer-1.0/libgstcoreelements.so /usr/local/lib/gstreamer-1.0/libgstvideorate.so /usr/local/lib/gstreamer-1.0/libgstrtp.so /usr/local/lib/gstreamer-1.0/libgstopusparse.so /usr/local/lib/gstreamer-1.0/libgstapp.so /usr/local/lib/gstreamer-1.0/libgstx264.so /usr/local/lib/gstreamer-1.0/libgstapp.so /usr/local/lib/gstreamer-1.0/libgstlibav.so /usr/local/lib/gstreamer-1.0/libgstvideoparsersbad.so /usr/local/lib/gstreamer-1.0/libgstopenh264.so /usr/local/lib/gstreamer-1.0/libgstvaapi.so /usr/local/lib/gstreamer-1.0/
COPY --from=builder /usr/local/lib/libgstapp-1.0.so.0 /usr/local/lib/libgsttag-1.0.so.0 /usr/local/lib/libgstrtp-1.0.so.0 /usr/local/lib/libgstpbutils-1.0.so.0 /usr/local/lib/libgstaudio-1.0.so.0 /usr/local/lib/libgstvideo-1.0.so.0 /usr/local/lib/libgstbase-1.0.so.0 /usr/local/lib/libgstreamer-1.0.so.0 /usr/local/lib/libgobject-2.0.so.0 /usr/local/lib/libglib-2.0.so.0 /usr/lib/x86_64-linux-gnu/libopus.so.0 /usr/lib/x86_64-linux-gnu/libvpx.so.4 /lib/x86_64-linux-gnu/libz.so.1 /usr/local/lib/liborc-0.4.so.0 /usr/local/lib/libgmodule-2.0.so.0 /usr/lib/x86_64-linux-gnu/libffi.so.6 /lib/x86_64-linux-gnu/libpcre.so.3 /usr/local/lib/libcrypto.so.1.1 /usr/local/lib/libssl.so.1.1 /usr/local/lib/libgstreamer-1.0.so.0 /usr/lib/x86_64-linux-gnu/libx264.so.148 /usr/local/lib/libgstcodecparsers-1.0.so.0 /usr/local/lib/libopenh264.so.4 /usr/local/lib/libva-drm.so.2 /usr/local/lib/libva-x11.so.2 /usr/local/lib/libva.so.2 /usr/local/lib/libgstallocators-1.0.so.0 /usr/lib/x86_64-linux-gnu/libXrandr.so.2 /usr/lib/x86_64-linux-gnu/libXrender.so.1 /usr/lib/x86_64-linux-gnu/libX11.so.6 /usr/lib/x86_64-linux-gnu/libXext.so.6 /usr/lib/x86_64-linux-gnu/libXfixes.so.3 /usr/lib/x86_64-linux-gnu/libdrm.so.2 /usr/lib/x86_64-linux-gnu/libva-wayland.so.1 /usr/lib/x86_64-linux-gnu/libwayland-client.so.0 /usr/lib/x86_64-linux-gnu/libxcb.so.1 /usr/lib/x86_64-linux-gnu/libva.so.1 /usr/lib/x86_64-linux-gnu/libXau.so.6 /usr/lib/x86_64-linux-gnu/libXdmcp.so.6 /lib/x86_64-linux-gnu/libbsd.so.0 /usr/local/lib/libcmrt.so.1 /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1 /usr/lib/x86_64-linux-gnu/libpciaccess.so.0 /usr/local/lib/
COPY --from=builder /usr/local/lib/dri /usr/local/lib/dri
COPY --from=builder /usr/local/bin/gst-inspect-1.0 /usr/local/bin/vainfo /usr/local/bin/

FROM base AS release
WORKDIR /go/src/app
COPY star_tribe.pm.key /etc/ssl/
COPY star_tribedev.pm.key /etc/ssl/
COPY star_tribe.pm.crt /etc/ssl/
COPY star_tribedev.pm.crt /etc/ssl/
COPY --from=builder /go/src/app/app mcu
RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/mcu.conf
RUN echo "/usr/local/lib/gstreamer-1.0" >> /etc/ld.so.conf.d/mcu.conf
RUN ldconfig -vvvvv
CMD /go/src/app/mcu
