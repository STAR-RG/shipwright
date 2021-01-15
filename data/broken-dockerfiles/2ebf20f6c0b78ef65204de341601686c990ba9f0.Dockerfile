#FROM manastech/crystal
FROM greyltc/archlinux
MAINTAINER Arthur Poulet <arthur.poulet@mailoo.org>

# Install crystal
RUN pacman -Syu --noprogressbar --noconfirm crystal shards llvm35 llvm35-libs clang35 base-devel libxml2

# Install shards
WORKDIR /usr/local
#RUN apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl git libssl-dev
#RUN curl -Lo bin/shards.gz https://github.com/crystal-lang/shards/releases/download/v0.6.3/shards-0.6.3_linux_x86_64.gz; gunzip bin/shards.gz; chmod 755 bin/shards

# Add this directory to container as /app
ADD . /transfer_more
WORKDIR /transfer_more

# Install dependencies
RUN shards install

# Build our app
RUN crystal build --release src/transfer_more.cr

# Run the tests
RUN mkdir /tmp/files
#RUN crystal spec

EXPOSE 3000

ENTRYPOINT ./transfer_more --port 3000
