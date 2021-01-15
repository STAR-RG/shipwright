
FROM kylef/swiftenv
RUN swiftenv install DEVELOPMENT-SNAPSHOT-2016-05-09-a

# install redis
RUN         cd /tmp && curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz >/dev/null 2>&1 && cd redis-stable && make >/dev/null 2>&1 && make install

# install openssl and libxml2
RUN apt-get install -y libssl-dev
RUN apt-get install -y libxml2-dev

WORKDIR /package
VOLUME /package

# mount in local sources via:  -v $(PWD):/package

CMD echo $PWD && ls -la && redis-server ./Redis/redis.conf && swift build -Xcc -I/usr/include/libxml2 && .build/debug/PackageSearcher && .build/debug/PackageCrawler && .build/debug/PackageExporter && .build/debug/Analyzer && .build/debug/DataUpdater && .build/debug/StatisticsUpdater
