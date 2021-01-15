FROM alpine

ARG BRANCH=manyuser
ARG WORK=~


RUN apk --no-cache add python \
	libsodium \
	wget


RUN mkdir -p $WORK && \
	wget -qO- --no-check-certificate https://github.com/HMBSbige/shadowsocksr/archive/$BRANCH.tar.gz | tar -xzf - -C $WORK


WORKDIR $WORK/shadowsocksr-$BRANCH/shadowsocks

ENTRYPOINT ["python", "server.py"]
