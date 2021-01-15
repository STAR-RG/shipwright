# Build a docker image for nginx on Ubuntu 14.04LTS.
# Use phusion/baseimage as base image.
# Based on https://github.com/mweibel/redis-docker/blob/master/Dockerfile
FROM phusion/baseimage:0.10.1
MAINTAINER  pitrho

# Set up the environment
#
ENV DEBIAN_FRONTEND noninteractive


# Install build deps
#
RUN apt-get update && apt-get -y -q install \
	build-essential tcl8.5 wget awscli dnsutils && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Create Redis user and data directory structure
#
RUN useradd redis
ENV REDIS_DATA_DIR /var/lib/redis
ENV REDIS_LOG_DIR /var/log/redis
ENV REDIS_PID_DIR /var/run/redis
RUN \
	mkdir -p $REDIS_LOG_DIR && \
	mkdir -p $REDIS_DATA_DIR && \
	mkdir -p $REDIS_PID_DIR && \
	chown redis:redis $REDIS_DATA_DIR && \
	chown redis:redis $REDIS_LOG_DIR && \
	chown redis:redis $REDIS_PID_DIR

# Download Redis source and install it
#
RUN wget http://download.redis.io/releases/redis-%%REDIS_VERSION%%.tar.gz
RUN tar -zxf redis-%%REDIS_VERSION%%.tar.gz
RUN \
	cd redis-%%REDIS_VERSION%% && \
	/usr/bin/make && \
	/usr/bin/make install && \
	REDIS_PORT=6379 \
		REDIS_CONFIG_FILE=/etc/redis/redis.conf \
		REDIS_LOG_FILE=${REDIS_LOG_DIR}/redis.log \
		REDIS_DATA_DIR=${REDIS_DATA_DIR} \
		REDIS_EXECUTABLE=/usr/local/bin/redis-server ./utils/install_server.sh && \
	update-rc.d -f redis_6379 remove && \
	cd .. && \
	rm -rf redis-%%REDIS_VERSION%%

# Modify the configuration
#
RUN sed -i 's/^daemonize yes/daemonize no/' /etc/redis/redis.conf \
	&& sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf \
	&& sed -i 's/^logfile \/var\/log\/redis\/redis.log/logfile ""/' /etc/redis/redis.conf

# Set logrotate for REDIS_LOG_DIR
RUN echo "${REDIS_LOG_DIR}/*.log {\n\tweekly\n\trotate 2\n\tcopytruncate\n\tdelaycompress\n\tcompress\n\tnotifempty\n\tmissingok\n\tsu root root\n}" > /etc/logrotate.d/redis

# Set entry point for my_init and add backup scripts
#
RUN mkdir /etc/service/redis
COPY start_redis.sh /etc/service/redis/run
COPY backup.sh /backup.sh
COPY enable_backups.sh /enable_backups.sh

# Expose ports for redis and sentinel
#
EXPOSE 6379 26379

# Use baseimage-docker's init system.
#
CMD ["/sbin/my_init"]
