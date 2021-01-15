FROM ubuntu:xenial
MAINTAINER Takatoshi Maeda <me@tmd.tw>

ENV PATH $PATH:/usr/local/go/bin:/usr/local/go/vendor/bin

RUN env DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y libwebp-dev libmagickwand-dev git wget && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV GOLANG_VERSION 1.9.2
ENV GOROOT /usr/local/go
ENV GOPATH /usr/local/go/vendor

ENV KINU_VERSION 1.0.0.alpha13
ENV KINU_BIND 0.0.0.0:80
ENV KINU_LOG_LEVEL info
ENV KINU_LOG_FORMAT ltsv
ENV KINU_RESIZE_ENGINE ImageMagick
ENV KINU_STORAGE_TYPE File
ENV KINU_FILE_DIRECTORY /var/local/kinu

RUN mkdir -p /tmp/golang && \
    wget https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz -q -P /tmp/golang && \
    cd /tmp/golang && \
    tar zxf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    mv ./go /usr/local/go && \
    mkdir /usr/local/go/vendor && \
    go get -d github.com/tokubai/kinu && \
    cd /usr/local/go/vendor/src/github.com/tokubai/kinu/ && \
    git fetch && git checkout refs/tags/${KINU_VERSION} && \
    go build -o /usr/local/bin/kinu . && \
    mkdir -p /var/local/kinu && \
    rm -rf /tmp/golang && \
    rm -rf /usr/local/go

CMD ["kinu"]
