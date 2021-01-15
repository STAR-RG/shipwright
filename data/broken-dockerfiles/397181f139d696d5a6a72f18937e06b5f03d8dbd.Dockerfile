FROM golang:1.10-alpine

RUN apk add --no-cache \
	ca-certificates \
	curl \
	git \
	gcc \
	libffi-dev \
	make \
	musl-dev \
	rpm \
	ruby \
	ruby-dev \
	tar

RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN go get -u github.com/alecthomas/gometalinter \
  && go get -u github.com/goreleaser/goreleaser

RUN gometalinter --install --update
RUN gem install --no-rdoc --no-ri fpm
