
FROM kylef/swiftenv

RUN swiftenv install DEVELOPMENT-SNAPSHOT-2016-08-18-a

# install redis
RUN cd /tmp && curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz >/dev/null 2>&1 && cd redis-stable && make >/dev/null 2>&1 && make install

# install libssl
RUN apt-get update && apt-get install -y libssl-dev

WORKDIR /package
VOLUME /package
EXPOSE 8080

# mount in local sources via:  -v $(PWD):/package

CMD redis-server ./Redis/redis.conf && swift build && .build/debug/Pong
