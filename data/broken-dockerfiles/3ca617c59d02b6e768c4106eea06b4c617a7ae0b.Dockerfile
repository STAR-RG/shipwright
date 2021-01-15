FROM automenta/narchy

RUN cd / ; git clone --depth 1 https://github.com/automenta/spimedb.git spimedb

# build: server (maven)
RUN cd /spimedb ; mvn install -U -Dmaven.test.skip=true

WORKDIR /spimedb
