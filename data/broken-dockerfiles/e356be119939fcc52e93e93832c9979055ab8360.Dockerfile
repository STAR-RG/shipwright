FROM v2ray/official
MAINTAINER HyperApp <hyperappcloud@gmail.com>

ARG BRANCH=manyuser
ARG WORK=/root

RUN apk --no-cache add python \
    libsodium \
    wget

RUN wget -qO- --no-check-certificate https://github.com/shadowsocksr/shadowsocksr/archive/$BRANCH.tar.gz | tar -xzf - -C $WORK



ENV SMART_PORT 8000
ENV USERNMAE admin
ENV PASSWORD smartsocks
EXPOSE $SMART_PORT

ADD server.py /usr/local/bin/smart-server
ADD ss-server.sh /usr/local/bin/ss-server

CMD smart-server -p $SMART_PORT -u $USERNAME -P $PASSWORD
