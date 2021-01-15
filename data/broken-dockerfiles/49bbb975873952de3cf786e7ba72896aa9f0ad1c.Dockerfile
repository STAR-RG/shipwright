# DOCKER-VERSION 1.0.0
FROM resin/rpi-raspbian

# install required packages, in one command
RUN apt-get update  && \
    apt-get install -y  python-dev

ENV PYTHON /usr/bin/python2

# install nodejs for rpi
RUN apt-get install -y wget && \
    wget http://node-arm.herokuapp.com/node_latest_armhf.deb && \
    dpkg -i node_latest_armhf.deb && \
    rm node_latest_armhf.deb && \
    apt-get autoremove -y wget

# install RPI.GPIO python libs
RUN apt-get install -y wget && \
     wget http://downloads.sourceforge.net/project/raspberry-gpio-python/raspbian-wheezy/python-rpi.gpio_0.5.11-1_armhf.deb && \
     dpkg -i python-rpi.gpio_0.5.11-1_armhf.deb && \
     rm python-rpi.gpio_0.5.11-1_armhf.deb && \
     apt-get autoremove -y wget

# install node-red
RUN apt-get install -y build-essential && \
    npm install -g --unsafe-perm  node-red && \
    apt-get autoremove -y build-essential

# install nodered nodes
RUN touch /usr/share/doc/python-rpi.gpio
COPY ./source /usr/local/lib/node_modules/node-red/nodes/core/hardware
RUN chmod 777 /usr/local/lib/node_modules/node-red/nodes/core/hardware/nrgpio

WORKDIR /root/bin
RUN ln -s /usr/bin/python2 ~/bin/python
RUN ln -s /usr/bin/python2-config ~/bin/python-config
env PATH ~/bin:$PATH

WORKDIR /root/.node-red
RUN npm install node-red-node-redis && \
    npm install node-red-contrib-googlechart && \
    npm install node-red-node-web-nodes 

# run application
EXPOSE 1880
#CMD ["/bin/bash"]
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
