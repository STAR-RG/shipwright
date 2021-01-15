FROM java:8-jre
MAINTAINER "European Environment Agency (EEA): IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

RUN apt-get update -q \
 && apt-get dist-upgrade -y \
 && apt-get install wget netcat net-tools python3-pip pwgen --no-install-recommends -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install chaperone

RUN mkdir -p /data /logs /conf /etc/chaperone.d

WORKDIR /opt/

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre

# Get graylog2 web and server and install into /opt/
ENV GRAYLOG_VERSION="2.2.3"
ENV GRAYLOG_SERVER="graylog-$GRAYLOG_VERSION"

RUN useradd -u 500 -s /bin/false -r -m graylog \
 && wget "http://packages.graylog2.org/releases/graylog/$GRAYLOG_SERVER.tgz" -q \
 && tar -xf "$GRAYLOG_SERVER.tgz" && rm "$GRAYLOG_SERVER.tgz" \
 && mv "$GRAYLOG_SERVER" graylog2 \
 && mkdir -p /etc/graylog/server/ \
 && cp graylog2/graylog.conf.example /etc/graylog/server/server.conf \
 && chown -R graylog /opt/graylog2 /etc/graylog

COPY config/log4j2.xml /etc/graylog/server/
ENV LOG4J="-Dlog4j.configurationFile=/etc/graylog/server/log4j2.xml"

# Setup basic config
RUN sed -i -e "s/mongodb:\/\/localhost\/graylog.*$/mongodb:\/\/mongodb\/graylog2/" /etc/graylog/server/server.conf \
 && sed -i -e "s/rest_listen_uri.*=.*$/rest_listen_uri = http:\/\/0.0.0.0:9000\/api\//" /etc/graylog/server/server.conf \
 && sed -i -e "s/#web_listen_uri.*=.*$/web_listen_uri = http:\/\/0.0.0.0:9000\//" /etc/graylog/server/server.conf \
 && sed -i -e "s/#web_enable_cors.*=.*$/web_enable_cors = true/" /etc/graylog/server/server.conf \
 && sed -i -e "s/allow_leading_wildcard_searches.*=.*$/allow_leading_wildcard_searches = true/" /etc/graylog/server/server.conf \
 && sed -i -e "s/allow_highlighting.*=.*$/allow_highlighting = true/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#elasticsearch_cluster_name.*=.*$/elasticsearch_cluster_name = graylog2/" /etc/graylog/server/server.conf \
 && sed -i -e "s/elasticsearch_prefix_index.*=.*$/elasticsearch_prefix_index = graylog2/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#elasticsearch_transport_tcp_port.*=.*$/elasticsearch_transport_tcp_port = 9350/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#elasticsearch_http_enabled.*=.*$/elasticsearch_http_enabled = false/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#elasticsearch_discovery_zen_ping_multicast_enabled.*=.*$/elasticsearch_discovery_zen_ping_multicast_enabled = false/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#elasticsearch_discovery_zen_ping_unicast_hosts.*=.*$/elasticsearch_discovery_zen_ping_unicast_hosts = elasticsearch:9300/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#elasticsearch_network_host.*=.*$/elasticsearch_network_host = 0.0.0.0/" /etc/graylog/server/server.conf \
 && sed -i -e "s/#content_packs_loader_enabled.*=.*$/content_packs_loader_enabled = true/" /etc/graylog/server/server.conf \
 && sed -i -e "s/-Xms1g -Xmx1g/\$GRAYLOG_HEAP_SIZE -Dgraylog2.installation_source=docker/g" /opt/graylog2/bin/graylogctl \
 && sed -i -e '/DEFAULT_JAVA_OPTS=/ i GRAYLOG_HEAP_SIZE=${GRAYLOG_HEAP_SIZE:=-Xms1g -Xmx1g}' /opt/graylog2/bin/graylogctl

EXPOSE 9000 12201/udp

COPY chaperone.conf /etc/chaperone.d/chaperone.conf
COPY ./setup.sh setup.sh

WORKDIR /opt/graylog2
COPY ./graylog_restart.sh check_restart.sh

ENTRYPOINT ["/usr/local/bin/chaperone"]
CMD []
