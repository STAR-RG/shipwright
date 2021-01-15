FROM ubuntu
RUN apt-get update && apt-get install -y wget unzip curl
RUN rm -f consul  
RUN wget -nc -q https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip; 
RUN unzip -q 0*; rm 0*; 
#RUN mkdir -p consul_ui; cd consul_ui; wget -nc -q https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip; 
#RUN unzip -q 0*; rm 0*;mv dist/* .
ADD bin/consul-externalservice_linux_amd64 /bin/consul-externalservice
ADD bin/start.sh /bin/start.sh
RUN chmod +x /bin/start.sh

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
#CMD "(/consul agent -server -bootstrap -data-dir /tmp/consul &) && (sleep 5) && (orkestrator &)"
CMD "/bin/start.sh"
