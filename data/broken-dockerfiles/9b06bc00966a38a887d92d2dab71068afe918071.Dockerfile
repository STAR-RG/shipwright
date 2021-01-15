FROM  neo4j:3.4.6-enterprise

RUN apk update && apk add --no-cache --quiet \
    e2fsprogs \
    curl \
	zip \
	unzip \
	python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip

# Install plugins
RUN mkdir -p /var/lib/neo4j/plugins
RUN curl -L -s https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.4.0.1/apoc-3.4.0.1-all.jar > /var/lib/neo4j/plugins/apoc-3.4.0.1-all.jar
RUN curl -L -s http://central.maven.org/maven2/mysql/mysql-connector-java/6.0.6/mysql-connector-java-6.0.6.jar > /var/lib/neo4j/plugins/mysql-connector-java-6.0.6.jar

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY init_db.sh /init_db.sh

# These were created earlier by image, but we dont need them since
# entrypoint will configure Neo to use them if they exist.
RUN rm -rf /var/lib/neo4j/data /var/lib/neo4j/logs

EXPOSE 5000 5001 6000 6001 7000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["neo4j"]
