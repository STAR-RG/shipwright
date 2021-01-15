FROM alpine:3.7
LABEL maintainer Uninett AS <system@uninett.no>
RUN apk update && apk add --no-cache ca-certificates=20171114-r0 && rm -rf /var/cache/apk/*
COPY goidc-proxy /bin/
USER nobody
CMD ["/bin/goidc-proxy"]
