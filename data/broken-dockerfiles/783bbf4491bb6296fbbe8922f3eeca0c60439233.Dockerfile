
# vbehar/openshift-dashboard
FROM openshift/origin-base

MAINTAINER Vincent Behar

LABEL io.k8s.description="Dashboard of resources from multiple OpenShift projects" \
      io.k8s.display-name="OpenShift Dashboard" \
      io.openshift.tags="openshift,dashboard"

ENV GO_VERSION=1.4.2 \
    GOPATH=/go/src/github.com/vbehar/openshift-dashboard/Godeps/_workspace \
    GOROOT=/go

COPY . /go/src/github.com/vbehar/openshift-dashboard/

RUN yum install -y gcc \
 && curl -jksSL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz | gunzip -c - | tar -xf - -C / \
 && /go/bin/go install github.com/vbehar/openshift-dashboard \
 && mv /go/bin/openshift-dashboard /openshift-dashboard \
 && mv /go/src/github.com/vbehar/openshift-dashboard/public / \
 && mv /go/src/github.com/vbehar/openshift-dashboard/templates / \
 && rm -rf /go \
 && yum clean all

EXPOSE 8080

CMD [ "/openshift-dashboard" ]
