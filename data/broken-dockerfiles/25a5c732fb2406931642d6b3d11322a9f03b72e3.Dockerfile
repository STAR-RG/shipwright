FROM debian

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends autoconf automake bison build-essential bzip2 ca-certificates curl g++ gawk gcc git libc6-dev libffi-dev libgdbm-dev libncurses5-dev libreadline6 libreadline6-dev libsqlite3-0 libsqlite3-dev libssl-dev libtool libxml2-dev libxslt1-dev libyaml-dev make openssl patch pkg-config procps sqlite3 subversion zlib1g zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN useradd -d /opt/beef -m -s /bin/bash beef
WORKDIR /opt/beef
COPY install.sh /opt/beef/
RUN su beef -lc ./install.sh
COPY run.sh /opt/beef/
CMD su beef -lc /opt/beef/run.sh
EXPOSE 3000
