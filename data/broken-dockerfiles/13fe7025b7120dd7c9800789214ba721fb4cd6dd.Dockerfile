FROM debian:stretch-slim
LABEL  maintainer="mle@counterflowai.com" domain="counterflow.ai"

RUN apt-get update --fix-missing
RUN apt-get install -y zlib1g-dev libluajit-5.1 liblua5.1-dev lua-socket libcurl4-openssl-dev libatlas-base-dev libhiredis-dev git make libmicrohttpd-dev
#
#
#
#RUN git clone https://github.com/counterflow-ai/dragonfly-mle; \
RUN git clone -b devel https://github.com/counterflow-ai/dragonfly-mle; \
    cd dragonfly-mle/src; make ; make install
RUN rm -rf dragonfly-mle
#
# Build redis
#
RUN git clone https://github.com/antirez/redis.git; \
    cd redis/src; make -j ; make install
RUN rm -rf redis
#
# Build redis ML
#
RUN git clone https://github.com/RedisLabsModules/redis-ml.git; \
    cd redis-ml/src; \
    make -j ; \
    mkdir /usr/local/lib ; \
    cp redis-ml.so /usr/local/lib
RUN rm -rf redis-ml
#
#
#
RUN mkdir -p /opt/suricata/var
RUN apt-get purge -y build-essential git make; apt-get -y autoremove
#
WORKDIR /usr/local/dragonfly-mle
ENTRYPOINT redis-server --loadmodule /usr/local/lib/redis-ml.so --daemonize yes && /usr/local/dragonfly-mle/bin/dragonfly-mle

