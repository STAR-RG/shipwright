FROM ubuntu:14.04

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git curl \
    cmake pkg-config libprotoc-dev libprotobuf8 protobuf-compiler \
    libprotobuf-dev libosmpbf-dev libpng12-dev libtbb-dev libbz2-dev \
    libstxxl-dev libstxxl-doc libstxxl1 libxml2-dev libzip-dev \
    libboost-all-dev lua5.1 liblua5.1-0-dev libluabind-dev libluajit-5.1-dev

RUN \
  git clone git://github.com/Project-OSRM/osrm-backend.git /src && \
  mkdir -p /build && \
  cd /build && \
  cmake /src && make && \
  mv /src/profiles/car.lua profile.lua && \
  mv /src/profiles/lib/ lib && \
  echo "disk=/tmp/stxxl,25000,syscall" > /build/.stxxl && \
  rm -rf /src

WORKDIR /build
ADD run.sh run.sh
EXPOSE 5000
