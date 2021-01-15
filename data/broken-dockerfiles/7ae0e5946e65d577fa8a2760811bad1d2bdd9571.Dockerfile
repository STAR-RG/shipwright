FROM golang:1.8-alpine3.6

MAINTAINER TFG Co <backend@tfgco.com>

RUN apk add --no-cache git curl jq

RUN go get -u github.com/Masterminds/glide/...

ADD . /go/src/github.com/topfreegames/mqttbot

WORKDIR /go/src/github.com/topfreegames/mqttbot
RUN glide install
RUN go install github.com/topfreegames/mqttbot

ENV MQTTBOT_MQTTSERVER_HOST localhost
ENV MQTTBOT_MQTTSERVER_PORT 1883
ENV MQTTBOT_MQTTSERVER_USER admin
ENV MQTTBOT_MQTTSERVER_PASS admin

ENV MQTTBOT_ELASTICSEARCH_HOST http://localhost:9200
ENV MQTTBOT_ELASTICSEARCH_SNIFF false

ENV MQTTBOT_REDIS_HOST localhost
ENV MQTTBOT_REDIS_PORT 6379
ENV MQTTBOT_API_TLS false
ENV MQTTBOT_API_CERTFILE ./misc/example.crt
ENV MQTTBOT_API_KEYFILE ./misc/example.key
ENV MQTTBOT_CONFIG_FILE ./config/local.yml

EXPOSE 5000

CMD ./start_docker.sh
