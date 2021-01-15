FROM java:8u102

MAINTAINER  Sharetribe Ltd. "http://github.com/sharetribe"
ENV REFRESHED_AT 2016-10-28

# Update the package repository
RUN apt-get update \
    && apt-get upgrade -y

RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o /usr/local/bin/lein \
	&& chmod 755 /usr/local/bin/lein

# Run as non-privileged user
RUN useradd -m -s /bin/bash app \
	&& mkdir /opt/app /var/log/app && chown -R app:app /opt/app /var/log/app
USER app

# Copy project file and download dependencies
COPY project.clj /opt/app/project.clj
WORKDIR /opt/app/
RUN ["lein", "deps"]

# Copy source code to /opt/app
COPY src/ /opt/app/src/
COPY resources/ /opt/app/resources/

# Install leiningen, compile search-api
RUN lein clean && lein uberjar

# Copy docker scripts
COPY docker/ /opt/app/docker/

# Copy release
COPY RELEASE /opt/app/

# Default JVM options for production
ENV HARMONY_JAVA_OPTS -server -Xms256m -Xmx768m -Xss512k -XX:+UseG1GC

# Defaults needed by entrypoint
EXPOSE 8085

# Start server
CMD ["docker/startup.sh"]
