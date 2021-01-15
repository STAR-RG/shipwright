FROM manastech/crystal
MAINTAINER Ian Blenke <ian@blenke.com>

# This is an example Dockerized Crystal Kemal project

# Install shards
WORKDIR /usr/local
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl git
RUN curl -Lo bin/shards.gz https://github.com/crystal-lang/shards/releases/download/v0.6.1/shards-0.6.1_linux_x86_64.gz; gunzip bin/shards.gz; chmod 755 bin/shards

# Add this directory to container as /app
ADD . /app
WORKDIR /app

# Install dependencies
RUN shards install

# Build our app
RUN crystal build --release src/app.cr

# Run the tests
RUN crystal spec

EXPOSE 3000

CMD ./app
