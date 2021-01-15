FROM golang:1.10 as builder
ARG HELM_CHART
ARG API_VERSION
ARG KIND
WORKDIR /go/src/github.com/operator-framework/helm-app-operator-kit/helm-app-operator
COPY helm-app-operator .
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN dep ensure -v
RUN CGO_ENABLED=0 GOOS=linux go build -o bin/operator cmd/manager/main.go
RUN chmod +x bin/operator

FROM alpine:3.6
ARG HELM_CHART
ARG API_VERSION
ARG KIND
ENV API_VERSION $API_VERSION
ENV KIND $KIND
WORKDIR /
COPY --from=builder /go/src/github.com/operator-framework/helm-app-operator-kit/helm-app-operator/bin/operator /operator
RUN apk add -U curl && \
    mkdir chart  && \
    curl "$HELM_CHART" | tar -xzv --strip-components=1 -C ./chart && \
    apk del curl && \
    rm -rf /var/cache/apk/*

ENV HELM_CHART /chart

CMD ["/operator"]
