FROM registry.svc.ci.openshift.org/ocp/builder:golang-1.13 AS builder
WORKDIR /go/src/github.com/openshift/cluster-etcd-operator
COPY . .
ENV GO_PACKAGE github.com/openshift/cluster-etcd-operator
RUN make build --warn-undefined-variables

FROM registry.svc.ci.openshift.org/ocp/4.4:base
COPY --from=builder /go/src/github.com/openshift/cluster-etcd-operator/bindata/bootkube/bootstrap-manifests /usr/share/bootkube/manifests/bootstrap-manifests/
COPY --from=builder /go/src/github.com/openshift/cluster-etcd-operator/bindata/bootkube/config /usr/share/bootkube/manifests/config/
COPY --from=builder /go/src/github.com/openshift/cluster-etcd-operator/bindata/bootkube/manifests /usr/share/bootkube/manifests/manifests/
COPY --from=builder /go/src/github.com/openshift/cluster-etcd-operator/cluster-etcd-operator /usr/bin/
COPY manifests/ /manifests

LABEL io.openshift.release.operator true
