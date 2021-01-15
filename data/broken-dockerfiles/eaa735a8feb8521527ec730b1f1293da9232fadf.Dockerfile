FROM swift:4.1

LABEL Description="TaskServer (swift) running on Docker" Vendor="Marcin Czachurski" Version="1.3"

# Install needed system libraries for MySQL access
RUN apt-get update \
	&& apt-get install -y openssl libssl-dev uuid-dev sqlite3 libsqlite3-dev --no-install-recommends

EXPOSE 8181

ADD . /server
WORKDIR /server

RUN swift build --configuration release
ENTRYPOINT .build/release/TaskerServerApp
