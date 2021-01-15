FROM golang:1-alpine

ENV version 0.2.2

# install govendor and fpm
RUN apk add --no-cache --quiet \
    ruby \
    ruby-dev \
    gcc \
    libffi-dev \
    make \
    libc-dev \
    rpm \
    govendor \
    git \
    tar \
    && gem install --quiet --no-ri --no-rdoc fpm

# create volume for files and directories to be served by Goup
RUN mkdir /data
VOLUME /data

# build Goup
ENV tarball_name goup_${version}_64-bit
RUN mkdir /${tarball_name}
RUN mkdir /go/src/goup
WORKDIR /go/src/goup
COPY . /go/src/goup
RUN govendor sync
ENV GOOS linux
ENV GOARCH amd64
ENV CGO_ENABLED 0
RUN go build -o /${tarball_name}/goup -ldflags "-X main.VERSION=${version}" -v .

# create packages
RUN mkdir /builds
WORKDIR /builds
RUN cp /${tarball_name}/goup .
ENV PATH /builds:${PATH}
RUN tar -czf ${tarball_name}.tar.gz /${tarball_name}/goup
RUN fpm -s dir -t deb --name goup --version ${version} /${tarball_name}/goup=/usr/local/bin/goup
RUN fpm -s dir -t rpm --name goup --version ${version} /${tarball_name}/goup=/usr/local/bin/goup

EXPOSE 4000

CMD ["goup", "-dir", "/data"]
