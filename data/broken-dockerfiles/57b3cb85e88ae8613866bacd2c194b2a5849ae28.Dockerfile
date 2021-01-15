FROM alpine

RUN apk add --no-cache go git musl-dev libstdc++ libc6-compat ca-certificates nodejs

COPY backend /data/go/src/github.com/qbin-io/backend
RUN GOPATH=/data/go go get github.com/Masterminds/glide &&\
    cd /data/go/src/github.com/qbin-io/backend && GOPATH=/data/go /data/go/bin/glide install &&\
    GOPATH=/data/go go get github.com/qbin-io/backend/cmd/qbin &&\
    apk del --no-cache go git musl-dev &&\
    mv /data/go/bin/qbin /usr/local/bin/qbin && rm -r /data/go &&\
    mkdir /data/certs

COPY frontend /data/frontend
COPY prism-server /data/prism-server
COPY eff_large_wordlist.txt /data/eff_large_wordlist.txt
COPY blacklist.regex /data/blacklist.regex
COPY launch.sh /data/launch

WORKDIR "/data"
EXPOSE 80 90
CMD ["/data/launch", "--http", ":80", "--tcp", ":90"]
