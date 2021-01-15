FROM ubuntu:14.04

# Install system dependencies
RUN DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && apt-get install -qqy curl

RUN curl -sSL https://get.docker.com/ubuntu/ | sh
RUN curl -L https://github.com/docker/compose/releases/download/1.4.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

COPY ./docker-compose.yml /duraark-system/docker-compose.yml
COPY ./scripts/deploy-system.sh /duraark-system/deploy-system.sh

RUN chmod +x /usr/local/bin/docker-compose /duraark-system/deploy-system.sh

WORKDIR /duraark-system

CMD ["/duraark-system/deploy-system.sh"]
