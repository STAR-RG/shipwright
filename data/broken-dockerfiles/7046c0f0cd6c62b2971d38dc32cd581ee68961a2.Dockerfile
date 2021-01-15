FROM mongo:3.2.8

MAINTAINER bwnyasse

USER root

# Install CRON
RUN apt-get update && \
    apt-get install -y cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Export
COPY ./export.sh /
RUN sed -i 's/\r$//' /export.sh && chmod +x /export.sh

# Dump
COPY ./dump.sh /
RUN sed -i 's/\r$//' /dump.sh && chmod +x /dump.sh

# Import
COPY ./import.sh /
RUN sed -i 's/\r$//' /import.sh && chmod +x /import.sh

# Starter
COPY ./start.sh /
RUN sed -i 's/\r$//' /start.sh && chmod +x /start.sh

VOLUME /backup
VOLUME /tmp/mongodb

#Instanciation of this container must override the command to provide the willing action : Export , Import or Dump
CMD ["./start.sh"]
