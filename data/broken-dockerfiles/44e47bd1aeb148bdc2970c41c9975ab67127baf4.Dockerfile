FROM alpine:edge
LABEL maintainer="dev@jpillora.com"

#install curl, openvpn, supervisor and latest cloud-torrent
RUN apk update && \
    apk add --no-cache curl openvpn supervisor && \
    VER=`curl -sI https://github.com/jpillora/cloud-torrent/releases/latest | grep Location | grep -E -o '[0-9\.]{5,}'` && \
    URL="https://github.com/jpillora/cloud-torrent/releases/download/$VER/cloud-torrent_linux_amd64.gz" && \
    curl -L "$URL" | gzip -d - > /usr/local/bin/cloud-torrent && \
    chmod +x /usr/local/bin/cloud-torrent

#setup opt/
RUN mkdir /opt
RUN mkdir /opt/openvpn
RUN mkdir /opt/cloud-torrent
RUN mkdir /opt/cloud-torrent/downloads
COPY scripts /opt/scripts

#configure supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /opt/supervisord.conf

#run!
ENTRYPOINT ["/usr/bin/supervisord","-c","/opt/supervisord.conf"]