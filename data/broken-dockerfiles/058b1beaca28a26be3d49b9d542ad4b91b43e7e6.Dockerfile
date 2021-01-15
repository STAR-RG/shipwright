
FROM carver/git

MAINTAINER Jason Carver <ut96caarrs@snkmail.com>

#The command order is intended to optimize for least-likely to change first, to speed up builds
RUN mkdir /var/log/skyline
RUN mkdir /var/run/skyline
RUN mkdir /var/log/redis

RUN apt-get install -y python-setuptools
RUN easy_install pip

#Need sudo as a NOOP
RUN apt-get install -y sudo

#Redis
RUN apt-get install -y wget
RUN wget http://download.redis.io/releases/redis-2.6.16.tar.gz
RUN tar --extract --gzip --directory /opt --file redis-2.6.16.tar.gz
RUN apt-get install -y gcc build-essential
RUN cd /opt/redis-2.6.16 && make

ENV PATH $PATH:/opt/redis-2.6.16/src

#numpy needs python build tools
RUN apt-get install -y python-dev
RUN pip install numpy

#scipy requires universe
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y python-scipy

RUN pip install pandas
RUN pip install patsy
RUN pip install statsmodels
RUN pip install msgpack-python

RUN git clone https://github.com/etsy/skyline.git /opt/skyline

RUN pip install -r /opt/skyline/requirements.txt

RUN cp /opt/skyline/src/settings.py.example /opt/skyline/src/settings.py

#security updates
RUN apt-get upgrade -y

ADD skyline-start.sh /skyline-start.sh
RUN chmod +x skyline-start.sh

ADD skyline-settings.py /opt/skyline/src/settings.py

WORKDIR /opt/skyline/bin

ENTRYPOINT ["/skyline-start.sh"]

#skyline webserver port
EXPOSE :1500

#graphite collection port
EXPOSE :2024
