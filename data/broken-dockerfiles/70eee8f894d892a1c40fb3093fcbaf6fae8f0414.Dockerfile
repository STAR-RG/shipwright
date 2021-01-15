
FROM resin/raspberrypi-python:3.4
ENV INITSYSTEM on

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y zookeeperd
RUN apt-get install -y libzmq3-dev

RUN pip install -vv numpy # this takes an hour to run!
RUN pip install kazoo
RUN pip install pyzmq
RUN pip install requests

COPY . /app
COPY zoo.cfg /etc/zookeeper/conf/zoo.cfg

WORKDIR /app

CMD ["./init.sh"]
