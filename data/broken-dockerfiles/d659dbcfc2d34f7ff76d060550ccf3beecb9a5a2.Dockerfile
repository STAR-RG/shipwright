FROM ubuntu:14.10
MAINTAINER tobe lihebin@wosai-inc.com

RUN apt-get -y update

# Install dependencies
RUN apt-get install -y curl git calibre && \
	curl -sL https://deb.nodesource.com/setup | bash - && \
	apt-get install -y nodejs && \
	npm install -g gitbook-cli

# Install latest version
RUN gitbook install 2.2.0

RUN mkdir /gitbook
WORKDIR /gitbook

EXPOSE 11135

CMD ["gitbook", "serve", "/gitbook"]