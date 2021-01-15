FROM ubuntu:cosmic as debian-based

WORKDIR /usr/local/node-hcrypt

COPY . /usr/local/node-hcrypt

RUN apt-get update && \
    apt-get -yy install libflint-2.5.2 libflint-dev libgmp-dev libmpfr-dev gcc g++ make automake autoconf gyp

RUN apt-get install -y curl && \
    curl --silent --location https://dev.nodesource.com/setup_10.x | sh - && \
    apt-get install -y nodejs npm && \
    npm i -g npx

