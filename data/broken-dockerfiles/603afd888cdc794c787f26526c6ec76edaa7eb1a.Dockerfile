FROM ubuntu:17.10
RUN apt-get update
RUN apt-get -y install make g++ swig libssl-dev cmake gawk libevent-dev libcurl4-openssl-dev libboost-dev nginx
RUN apt-get -y install curl less vim
RUN apt-get -y install python-pip
COPY s2map-server/ /usr/src/myapp/s2map-server
WORKDIR /usr/src/myapp/s2map-server
RUN make
RUN ldconfig
COPY frontend/ /usr/src/myapp/frontend
WORKDIR /usr/src/myapp/frontend
RUN pip install -r requirements.txt
COPY run-all.sh /usr/src/myapp/
WORKDIR /usr/src/myapp
COPY nginx.conf /etc/nginx/sites-enabled/proxy.conf
RUN rm /etc/nginx/sites-enabled/default
CMD ["/usr/src/myapp/run-all.sh"]
# RUN apt-get -y install python python-pip
#CMD ["python", "-m", "SimpleHTTPServer", "8000"]
EXPOSE 81
