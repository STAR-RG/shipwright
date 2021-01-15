# Define the base image.
FROM centos:latest
# Set environment variables.
ENV kafka_ver=2.12
ENV kafka_rel=1.0.1
# Create dirs.
RUN cd /root && \
    mkdir src && \
    mkdir soft && \
    mkdir shell && \
    mkdir logs
# Add files
ADD shell /root/shell
# Set up the environment.
# Install tools.
RUN yum update -y && \
    yum install -y bash sudo psmisc git go wget java-1.8.0-openjdk && \
    yum clean all && \
# Clone goim
    cd /root/src && \
    git clone https://github.com/Terry-Mao/goim.git && \
# Download&Install Apache Kafka
    cd /root/soft && \
    wget http://www-us.apache.org/dist/kafka/$kafka_rel/kafka_$kafka_ver-$kafka_rel.tgz && \
    tar -xzf kafka_$kafka_ver-$kafka_rel.tgz && \
    rm -rf kafka_$kafka_ver-$kafka_rel.tgz && \
    cd /root/soft/kafka_$kafka_ver-$kafka_rel && \
    mkdir /root/config && \
    mv ./config/zookeeper.properties /root/config/ && \
    ln -s /root/config/zookeeper.properties ./config/zookeeper.properties && \
    mv ./config/server.properties /root/config/ && \
    ln -s /root/config/server.properties ./config/server.properties && \
# Download the dependences.
    cd /root/src && \
    go get -u github.com/thinkboy/log4go && \
    go get -u github.com/Terry-Mao/goconf && \
    go get -u github.com/gorilla/websocket && \
    go get -u github.com/Shopify/sarama && \
    go get -u github.com/wvanbergen/kazoo-go && \
    \cp -rf goim /root/go/src/ && \
    mkdir /root/go/src/golang.org && \
    mkdir /root/go/src/golang.org/x && \
    cd /root/go/src/golang.org/x && \
    git clone https://github.com/golang/net.git && \
    cd /root/go/src/github.com/wvanbergen && \
    git clone https://github.com/wvanbergen/kafka.git && \
# Start compiling
# Building router
    cd /root/go/src/goim/router && \
    go build && \
    mkdir /root/soft/router && \
    \cp -rf router /root/soft/router/ && \
    \cp -rf router-example.conf /root/config/router.conf && \
    ln -s /root/config/router.conf /root/soft/router/router.conf && \
    \cp -rf router-log.xml /root/soft/router/router-log.xml && \
# Building comet
    cd /root/go/src/goim/comet && \
    go build && \
    mkdir /root/soft/comet && \
    \cp -rf comet /root/soft/comet/ && \
    \cp -rf comet-example.conf /root/config/comet.conf && \
    ln -s /root/config/comet.conf /root/soft/comet/comet.conf && \
    \cp -rf comet-log.xml /root/soft/comet/comet-log.xml && \
# Building job
    cd /root/go/src/goim/logic/job && \
    go build && \
    mkdir /root/soft/job && \
    \cp -rf job /root/soft/job/ && \
    \cp -rf job-example.conf /root/config/job.conf && \
    ln -s /root/config/job.conf /root/soft/job/job.conf && \
    \cp -rf job-log.xml /root/soft/job/job-log.xml && \
# Building logic
    cd /root/go/src/goim/logic && \
    go build && \
    mkdir /root/soft/logic && \
    \cp -rf logic /root/soft/logic/ && \
    \cp -rf logic-example.conf /root/config/logic.conf && \
    ln -s /root/config/logic.conf /root/soft/logic/logic.conf && \
    \cp -rf logic-log.xml /root/soft/logic/logic-log.xml && \
# Building client
    cd /root/go/src/goim/comet/client && \
    go build && \
    mkdir /root/soft/client && \
    \cp -rf client /root/soft/client/ && \
    \cp -rf client-example.conf /root/config/client.conf && \
    ln -s /root/config/client.conf /root/soft/client/client.conf && \
    \cp -rf log.xml /root/soft/client/log.xml && \
# Cleaning up
    yum autoremove -y git go wget && \
    rm -rf /root/src && \
    rm -rf /root/go && \
# Permission setting up
    chmod -R 777 /root/shell && \
    ln -s /root/shell/start.sh /root/start.sh && \
    ln -s /root/shell/stop.sh /root/stop.sh
# Volume settings
VOLUME ["/root/logs","/root/config"]
# Port settings
EXPOSE 1999
EXPOSE 2181
EXPOSE 6971
EXPOSE 6972
EXPOSE 7170
EXPOSE 7171
EXPOSE 7172
EXPOSE 7270
EXPOSE 7271
EXPOSE 7371
EXPOSE 7372
EXPOSE 7373
EXPOSE 7374
EXPOSE 8080
EXPOSE 8090
EXPOSE 8092
# Startup command
CMD /bin/bash -c /root/start.sh