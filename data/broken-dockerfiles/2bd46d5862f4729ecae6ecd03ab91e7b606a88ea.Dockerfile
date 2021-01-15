# Step one: build compliance-operator
FROM registry.access.redhat.com/ubi8/go-toolset as builder

WORKDIR /go/src/github.com/openshift/compliance-operator

ENV GOFLAGS=-mod=vendor

COPY . .
RUN make manager

# Step two: containerize compliance-operator
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

ENV OPERATOR=/usr/local/bin/compliance-operator \
    USER_UID=1001 \
    USER_NAME=compliance-operator

# install operator binary
COPY --from=builder /go/src/github.com/openshift/compliance-operator/build/_output/bin/compliance-operator ${OPERATOR}

COPY build/bin /usr/local/bin
RUN  /usr/local/bin/user_setup

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}
