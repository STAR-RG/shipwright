FROM ubuntu:14.10
MAINTAINER Saltobserver Maintainers <https://www.github.com/analogbyte/saltobserver/>

ENV DEBIAN_FRONTEND noninteractive

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

RUN apt-get update && apt-get install -y python-pip python-dev wget


ADD . /opt/code
WORKDIR /opt/code
RUN pip install .

WORKDIR /opt/code/saltobserver/static
RUN ./get_dependencies.sh
WORKDIR /opt/code

ENV SALTOBSERVER_SETTINGS /opt/code/saltobserver/config.py
ENV SALTOBSERVER_USE_CDN 0
ENV LOG_FILE /log/app.log

VOLUME /log
EXPOSE 8000

CMD gunicorn --log-file=/log/saltobserver_gunicorn.log -k flask_sockets.worker -b 0.0.0.0:8000 saltobserver:app
