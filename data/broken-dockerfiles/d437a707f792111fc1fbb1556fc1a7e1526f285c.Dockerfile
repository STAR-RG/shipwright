FROM alpine:3.6

COPY . /work/

RUN cd /work && \
    apk update && \
    apk add go=1.8.3-r0 git musl-dev && \
    apk add ethtool ipfw iptables ip6tables iproute2 sudo && \
    mkdir -p gopath/src/github.com/tylertreat && \
    ln -s $(pwd)/comcast gopath/src/github.com/tylertreat/ && \
    export GOPATH=$(pwd)/gopath && \
    \
    cd comcast && \
    patch -p1 <../docker-comcast.patch && \
    go get -d . && \
    go test -v ./... && \
    go build . && \
    cd .. && \
    \
    apk del go git musl-dev && \
    rm -r gopath /var/cache/* && \
    \
    rm /usr/bin/nsenter && \
    ln -s $(pwd)/nsenter-2015-07-28 /usr/bin/nsenter && \
    ln -s $(pwd)/findveth.sh        /usr/bin/ && \
    ln -s $(pwd)/comcast/comcast    /usr/bin/

# Needed to make sure the actual application of rules happens
ENTRYPOINT ["nsenter", "--target", "1", "--net", "comcast"]
