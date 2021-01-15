# use clair native image
FROM quay.io/coreos/clair:v1.2.6

# upgrade packages
RUN apt-get update && \
    apt-get dist-upgrade -y

# add supervisor for our multiprocess container
RUN apt-get install -y supervisor && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD supervisord.conf /etc/supervisord.conf
ADD run.sh /run.sh

# add configurations
ADD clair.yaml /etc/clair/config.yaml
ADD skipper.eskip /etc/skipper.eskip

# add skipper
ADD vendor/github.com/zalando /go/src/github.com/zalando
RUN go get -v github.com/zalando/skipper/cmd/skipper
RUN go install -v github.com/zalando/skipper/cmd/skipper
EXPOSE 8080

# add receiver and sender
ADD . /go/src/github.com/zalando/clair-sqs
RUN go install -v github.com/zalando/clair-sqs/cmd/receiver
RUN go install -v github.com/zalando/clair-sqs/cmd/sender

ENTRYPOINT ["/run.sh"]
