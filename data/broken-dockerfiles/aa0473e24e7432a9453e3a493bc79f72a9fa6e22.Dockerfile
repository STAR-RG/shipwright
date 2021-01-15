# build stage
FROM golang:1.10-stretch AS build-env
RUN mkdir -p /go/src/github.com/pipo02mix/grumpy
WORKDIR /go/src/github.com/pipo02mix/grumpy
COPY  . .
RUN useradd -u 10001 webhook
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o grumpywebhook

FROM scratch
COPY --from=build-env /go/src/github.com/pipo02mix/grumpy/grumpywebhook .
COPY --from=build-env /etc/passwd /etc/passwd
USER webhook
ENTRYPOINT ["/grumpywebhook"]