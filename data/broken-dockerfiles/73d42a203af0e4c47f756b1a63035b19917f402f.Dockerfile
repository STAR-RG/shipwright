# cb4
#
# VERSION               0.1.0

FROM ubuntu:18.04

ENV HOME="/root"

# Install dependencies
COPY ./sources.list /etc/apt/
RUN apt-get update && \
    apt-get install -y python python3-dev python3-pip curl git mmdb-bin && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# Install node.js
ENV NVM_DIR="$HOME/.nvm"
RUN \. "$NVM_DIR/nvm.sh" && nvm install 9

# Enable IP Geo-Location
RUN curl "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz" | gunzip -c > GeoLite2-City.mmdb

# Copy the cb4 dependencies
COPY ./package.json ./requirements.txt /srv/cb4/
WORKDIR /srv/cb4

# Install python and node dependencies
RUN \. "$NVM_DIR/nvm.sh" && nvm use 9 && \
    npm install --registry=https://registry.npm.taobao.org
RUN pip3 install -r ./requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/

# Build node modules
COPY ./vj4/ui /srv/cb4/vj4/ui
COPY ./scripts /srv/cb4/scripts
RUN \. "$NVM_DIR/nvm.sh" && nvm use 9 && npm run build

# Copy the cb4 files
COPY ./vj4 /srv/cb4/vj4
COPY ./.git /srv/cb4/.git
COPY ./pm /usr/local/bin/

# Start the server

ENV HOST="localhost" \
    PORT=34765 \
    URL_PREFIX="localhost" \
    OAUTH="" \
    OAUTH_CLIENT_ID="" \
    OAUTH_CLIENT_SECRET="" \
    DB_HOST="localhost" \
    DB_NAME="cb4-production" \
    MQ_HOST="localhost" \
    MQ_VHOST="/" \
    MOSS_USER_ID=987654321

EXPOSE $PORT

CMD python3 -m vj4.server \
    --listen=http://$HOST:$PORT \
    --url-prefix=$URL_PREFIX \
    --oauth=$OAUTH \
    --oauth-client-id=$OAUTH_CLIENT_ID \
    --oauth-client-secret=$OAUTH_CLIENT_SECRET \
    --db-host=$DB_HOST \
    --db-name=$DB_NAME \
    --mq-host=$MQ_HOST \
    --mq_vhost=$MQ_VHOST \
    --moss-user-id=$MOSS_USER_ID
