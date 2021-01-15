FROM registry.svc.ci.openshift.org/ocp/builder:golang-1.13 AS builder
WORKDIR /go/src/github.com/openshift/service-ca-operator
COPY . .
ENV GO_PACKAGE github.com/openshift/service-ca-operator
RUN go build -ldflags "-X $GO_PACKAGE/pkg/version.versionFromGit=$(git describe --long --tags --abbrev=7 --match 'v[0-9]*')" ./cmd/service-ca-operator

FROM registry.svc.ci.openshift.org/ocp/4.4:base
COPY --from=builder /go/src/github.com/openshift/service-ca-operator/service-ca-operator /usr/bin/
COPY manifests /manifests
# Using the vendored CRD ensures compatibility with 'oc explain'
COPY vendor/github.com/openshift/api/operator/v1/0000_50_service-ca-operator_02_crd.yaml /manifests/02_crd.yaml
ENTRYPOINT ["/usr/bin/service-ca-operator"]
LABEL io.openshift.release.operator=true
