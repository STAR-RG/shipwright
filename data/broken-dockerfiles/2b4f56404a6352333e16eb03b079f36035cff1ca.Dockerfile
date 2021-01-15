# GNAS-Linuxserver.io HTPC Templates for Portainer
#
# VERSION 0.0.3

FROM alpine:stable-latest

EXPOSE 80

COPY templates.json /usr/share/nginx/html/templates.json
