FROM crystallang/crystal:0.23.1

# Install Dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y --no-install-recommends libpq-dev libsqlite3-dev libmysqlclient-dev libreadline-dev git curl vim netcat

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs


# Install Amber
ENV PATH /app/bin:$PATH
WORKDIR /app
COPY shard.yml shard.lock /app/
RUN shards build amber

# Add Project
ADD . /app

# Set config
CMD amber watch
