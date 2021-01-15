FROM golang:1.8.3
RUN go get github.com/rancher/trash
RUN go get github.com/golang/lint/golint
RUN curl -sL https://get.docker.com/builds/Linux/x86_64/docker-1.10.3 > /usr/bin/docker && \
    chmod +x /usr/bin/docker
ENV PATH /go/bin:$PATH
ENV DAPPER_SOURCE /go/src/github.com/rancher/kubernetes-agent
ENV DAPPER_OUTPUT bin dist
ENV DAPPER_DOCKER_SOCKET true
ENV DAPPER_RUN_ARGS --privileged -v /var/lib/docker
ENV DAPPER_ENV TAG REPO
ENV GO15VENDOREXPERIMENT 1
ENV TRASH_CACHE ${DAPPER_SOURCE}/.trash-cache
RUN apt-get update && \
    apt-get install -y kmod iptables
WORKDIR ${DAPPER_SOURCE}
ENTRYPOINT ["./scripts/entry"]
CMD ["ci"]
