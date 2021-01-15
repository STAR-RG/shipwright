FROM nginx:1.7

RUN apt-get -yqq update && apt-get -yqq install ca-certificates procps

COPY swarm /
COPY default.conf /etc/nginx/conf.d/default.conf
COPY boot.sh /

EXPOSE 80 4243

CMD ["/boot.sh"]
