FROM golang:1.8-stretch

ENV APP_HOME $GOPATH/src/github.com/bytearena/docker-healthcheck-watcher

COPY . $APP_HOME

WORKDIR $APP_HOME/cmd/daemon
RUN go get -v ./...
RUN go build

CMD ["daemon"]
