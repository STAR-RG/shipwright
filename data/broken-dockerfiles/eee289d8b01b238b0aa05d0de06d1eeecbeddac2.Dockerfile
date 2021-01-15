FROM numenta/nupic

MAINTAINER Zac Gross <zacgross@gmail.com>

# Clone Cerebro repository 
RUN git clone https://github.com/numenta/nupic.cerebro.git /usr/local/src/nupic.cerebro

# Install dependencies
# Install Mongo
RUN \
    apt-get install -y libevent-dev;\
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10;\
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list;\
    dpkg-divert --local --rename --add /sbin/initctl;\
    ln -s /bin/true /sbin/initctl;\
    apt-get update;\
    apt-get install -y mongodb-10gen;\
    mkdir /usr/local/data/;\
    mkdir /usr/local/data/mongo;\
    pip install -r /usr/local/src/nupic.cerebro/requirements.txt;\
#RUN


EXPOSE 1955

ENTRYPOINT ["/bin/bash", "-c", "cd /usr/local/src/nupic.cerebro; mongod --dbpath /usr/local/data/mongo --smallfiles & python cerebro.py 1955"]


